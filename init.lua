local M = {}

local pcall, tostring, type, require, loadstring, io_stderr, io_write, io_read, table_insert, table_concat, table_pack, table_unpack, print =
       pcall, tostring, type, require, loadstring, io.stderr, io.write, io.read, table.insert, table.concat, table.pack, table.unpack, print

local readline
do
	local ok, libreadline = pcall( require, 'readline' )
	if ok then
		readline = libreadline.readline
	else
		function readline( prompt )
			io_write( promp )
			return io_read()
		end
	end
end

local function is_incomplete( err )
	--[[U G L Y    H A C K]]--
	return not not err:match( 'expected.-near %<eof%>%s*$' )
end

local function write_error( err )
	local ok, str = pcall( tostring, err )
	if not ok then
		str = 'error object is a (' .. type( err ) .. ')'
	end
	io_stderr:write( str )
	io_stderr:write( '\n' )
end

local function call_func( fun )
	local res = table_pack( pcall( fun ))
	if res[ 1 ] then
		if res.n > 1 then
			print( table_unpack( res, 2, res.n ))
		end
	else
		write_error( res[ 2 ] )
	end
end

local level1 = true
local can_return = false
local buf = {}

function M.interact()
	while true do
		local line = readline( level1 and (_PROMPT or '> ') or (_PROMPT2 or '>> '))
		if line then
			if level1 then
				local fun, err
				fun, err = loadstring( 'return ' .. line )
				if err then
					can_return = false
					fun, err = loadstring( line )
				else
					can_return = true
				end
				if fun then
					call_func( fun )
				else
					--is it just incomplete syntax or an unrecoverable syntax error?
					if is_incomplete( err ) then
						level1 = false
						buf = { line }
					else
						write_error( err )
					end
				end
			else
				table_insert( buf, line )
				local src = table_concat( buf, '\n' )
				local fun, err
				fun, err = loadstring( 'return ' .. src )
				if err then
					can_return = false
					fun, err = loadstring( src )
				else
					can_return = true
				end
				if fun then
					call_func( fun )
					level1 = true
					buf = nil
				else
					if is_incomplete( err ) then
						--keep reading
					else
						level1 = true
						write_error( err )
					end
				end
			end
		else
			break
		end
	end
end

return M

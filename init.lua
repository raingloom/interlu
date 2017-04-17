local M = {}

local pcall, tostring, type, require, loadstring, io_stderr, table_insert, table_concat, table_pack, table_unpack, print =
       pcall, tostring, type, require, loadstring, io.stderr, table.insert, table.concat, table.pack, table.unpack, print

local function isIncomplete( err )
	return not not err:match'expected.-near %<eof%>%s*$'
end

local function writeerr( err )
	local ok, str = pcall( tostring, err )
	if not ok then
		str = 'error is (' .. type( err ) .. ')'
	end
	io_stderr:write( str )
	io_stderr:write'\n'
end

local function runfun( fun )
	local pRes = table_pack( pcall( fun ))
	if pRes[ 1 ] then
		print( table_unpack( pRes, 2, pRes.n ))
	else
		writeerr( pRes[ 2 ] )
	end
end

local readline = require 'readline'
local level1 = true
local canreturn = false
local buf = {}

function M.interact()
	while true do
		local line = readline.readline( level1 and (_PROMPT or '>') or (_PROMP2 or '>>'))
		if line then
			if level1 then
				local fun, err
				fun, err = loadstring( 'return ' .. line )
				if err then
					canreturn = false
					fun, err = loadstring( line )
				else
					canreturn = true
				end
				if fun then
					runfun( fun )
				else
					--is it just incomplete syntax or an unrecoverable syntax error?
					if isIncomplete( err ) then
						level1 = false
						buf = { line }
					else
						writeerr( err )
					end
				end
			else
				table_insert( buf, line )
				local src = table_concat( buf, '\n' )
				local fun, err
				fun, err = loadstring( 'return ' .. src )
				if err then
					canreturn = false
					fun, err = loadstring( src )
				else
					canreturn = true
				end
				if fun then
					runfun( fun )
					level1 = true
					buf = nil
				else
					if isIncomplete( err ) then
						--keep reading
					else
						writeerr( err )
					end
				end
			end
		else
			break
		end
	end
end


return M

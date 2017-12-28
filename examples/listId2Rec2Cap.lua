local m = require'lpeglabel'
local re = require'relabel'

local terror = {
  ErrId     =  "expecting an identifier",
  ErrComma  =  "expecting ','"
}

local subject, errors

function recorderror(pos, lab)
	local line, col = re.calcline(subject, pos)
	table.insert(errors, { line = line, col = col, msg = terror[lab] })
end

function record (lab)
	return (m.Cp() * m.Cc(lab)) / recorderror
end

function sync (p)
	return (-p * m.P(1))^0
end

function defaultValue ()
	return m.Cc"NONE" 
end

local id = m.R'az'^1

local g = m.P{
  "S",
  S = m.V"Id" * m.V"List",
  List = -m.P(1) + m.V"Comma" * m.V"Id" * m.V"List",
  Id = m.V"Sp" * m.C(id) + m.T'ErrId',
  Comma = m.V"Sp" * "," + m.T'ErrComma',
  Sp = m.S" \n\t"^0,
  ErrId = record('ErrId') * sync(m.P",") * defaultValue(), 
  ErrComma = record('ErrComma') * sync(id),
}


function mymatch (g, s)
	errors = {}
	subject = s	
	io.write("Input: ", s, "\n")
	local r = { g:match(s) }
	io.write("Captures (separated by ';'): ")
	for k, v in pairs(r) do
		io.write(v .. "; ")
	end
	io.write("\nSyntactic errors found: " .. #errors)
	if #errors > 0 then
		io.write("\n")
		local out = {}
    for i, err in ipairs(errors) do
    	local msg = "Error at line " .. err.line .. " (col " .. err.col .. "): " .. err.msg
      table.insert(out,  msg)
    end
    io.write(table.concat(out, "\n"))
  end
	print("\n")
	return r
end
  
mymatch(g, "one,two")
mymatch(g, "one two three")
mymatch(g, "1,\n two, \n3,")
mymatch(g, "one\n two123, \nthree,")

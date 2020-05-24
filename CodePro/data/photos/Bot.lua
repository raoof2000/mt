package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'.. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
tdbot = dofile('./libs/tdbot.lua')
serpent = (loadfile "./libs/serpent.lua")()
feedparser = (loadfile "./libs/feedparser.lua")()
Config = (loadfile "./data/Config.lua")()
require('./libs/lua-redis')
URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
ltn12 = require "ltn12"
json = (loadfile "./libs/JSON.lua")()
mimetype = (loadfile "./libs/mimetype.lua")()
redis = (loadfile "./libs/redis.lua")()
JSON = (loadfile "./libs/dkjson.lua")()
EndMsg = " ツ"
gp_sudo = Config.gp_sudo
RedisIndex = Config.RedisIndex
bot_token = Config.bot_token
channel_username = Config.channel_username
channel_inline = Config.channel_inline
sudo_username = Config.sudo_username
SUDO = Config.SUDO
Bot_id = Config.Bot_id
Bot_idapi = Config.Bot_idapi
UsernameApi = Config.UsernameApi
link_poshtibani = Config.link_poshtibani
sudoinline_username = Config.sudoinline_username
sudo_name = Config.sudo_name
linkpardakht = Config.linkpardakht
UsernameCli = Config.UsernameCli
userpasswd = Config.userpasswd
local lgi = require ('lgi')
local notify = lgi.require('Notify')
notify.init ("Telegram updates")
chats = {}
local color = {
black = {"\027[30m", "\027[40m"},
red = {"\027[31m", "\027[41m"},
green = {"\027[32m", "\027[42m"},
yellow = {"\027[33m", "\027[43m"},
blue = {"\027[34m", "\027[44m"},
magenta = {"\027[35m", "\027[45m"},
cyan = {"\027[36m", "\027[46m"},
white = {"\027[37m", "\027[47m"},
default = "\027[00m"
}
local bot_profile = 'cli'
local clock = os.clock
function sleep(time)
	local t0 = clock()
while clock() - t0 <= time do end
end
function openChat(chat_id)
	assert (tdbot_function ({_ = "openChat", chat_id = chat_id}, dl_cb, nil))
end
function sendaction(chatid, action,progress)
	assert (tdbot_function ({
	_ = 'sendChatAction',
	chat_id = chatid,
	action = {
	_ = 'chatAction' .. action,
	progress = progress or 100
	},
	},  dl_cb,nil))
end
function do_notify (user, msg)
	local n = notify.Notification.new(user, msg)
	n:show ()
end
function serpdump(value)
	print(serpent.block(value, {comment=false}))
end
function vardump(value, depth, key)
	local linePrefix = ""
	local spaces = ""
	if key ~= nil then
		linePrefix = ""..key.." = "
	end
	if depth == nil then
		depth = 0
	else
		depth = depth + 1
		for i=1, depth do
			spaces = spaces .. "  "
		end
	end
	if type(value) == 'table' then
		mTable = getmetatable(value)
		if mTable == nil then
			print(spaces ..linePrefix.." (table)")
		else
			print(spaces .."(metatable) ")
			value = mTable
		end
		for tableKey, tableValue in pairs(value) do
			vardump(tableValue, depth, tableKey)
		end
	elseif type(value)  == 'function' or type(value) == 'thread' or type(value) == 'userdata' or value == nil then
		print(spaces..tostring(value))
	else
		print(spaces..linePrefix..tostring(value))
	end
end
function load_data(filename)
	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)
	return data
end
function save_data(filename, data)
	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()
end
function whoami()
	local usr = io.popen("whoami"):read('*a')
	usr = string.gsub(usr, '^%s+', '')
	usr = string.gsub(usr, '%s+$', '')
	usr = string.gsub(usr, '[\n\r]+', ' ')
	if usr:match("^root$") then
		tcpath = '/root/.telegram-bot/'..bot_profile
	elseif not usr:match("^root$") then
		tcpath = '/home/'..usr..'/.telegram-bot/'..bot_profile
	end
end
whoami()
function print_msg(msg)
	text = color.green[1].."[From: "..(msg.from.first_name or msg.to.title).."]\n"..color.yellow[1].."["..os.date("%H:%M:%S").."]"..color.red[1].."[Type :"
	if msg.forwarded then
		text = color.magenta[1].."[Forwarded from:"..(msg.forwarded_from_user or msg.forwarded_from_chat).."]"..text
	end
	if msg.edited then
		text = color.magenta[1].."[Edited]"..text
	end
	if msg.text then
		text = text.."Text]\n"..color.default..msg.text
	else
		if msg.media.caption and msg.media.caption ~= "" then
			if msg.photo then
				text = text.."Photo]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.video then
				text = text.."Video]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.videonote then
				text = text.."Videonote]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.voice then
				text = text.."Voice]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.audio then
				text = text.."Audio]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.animation then
				text = text.."Gif]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.sticker then
				text = text.."Sticker]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.contact then
				text = text.."Contact]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.document then
				text = text.."File]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			elseif msg.location then
				text = text.."Location]\n"..color.cyan[1].."Caption: "..color.default..msg.media.caption
			end
		else
			if msg.photo then
				text = text.."Photo] "..color.default
			elseif msg.video then
				text = text.."Video] "..color.default
			elseif msg.videonote then
				text = text.."Videonote] "..color.default
			elseif msg.voice then
				text = text.."Voice] "..color.default
			elseif msg.audio then
				text = text.."Audio] "..color.default
			elseif msg.animation then
				text = text.."Gif] "..color.default
			elseif msg.sticker then
				text = text.."Sticker] "..color.default
			elseif msg.contact then
				text = text.."Contact] "..color.default
			elseif msg.document then
				text = text.."File] "..color.default
			elseif msg.location then
				text = text.."Location] "..color.default
			end
		end
	end
	if msg.pinned then
		text = color.green[1].."[From: "..(msg.from.first_name or msg.to.title).."]\n"..color.yellow[1].."["..os.date("%H:%M:%S").."]\n"..color.red[1].."Pinned a message in chat: "..color.default..msg.to.title
	end
	if msg.game then
		text = text.."Game] "..color.default
	end
	if msg.adduser then
		text = text.."AddUser]"..color.default
	end
	if msg.deluser then
		text = ""
	end
	if msg.joinuser then
		text = text.."JoinGroup]"..color.default
	end
	print(text)
end
function var_cb(msg, data)
	bot = {}
	msg.to = {}
	msg.from = {}
	msg.media = {}
	msg.id = msg.id
	msg.to.type = gp_type(data.chat_id)
	if data.content and data.content.caption then
		msg.media.caption = data.content.caption
	end
	
	if data.reply_to_message_id ~= 0 then
		msg.reply_id = data.reply_to_message_id
	else
		msg.reply_id = false
	end
	function get_gp(arg, data)
		if gp_type(msg.chat_id) == "channel" or gp_type(msg.chat_id) == "chat" then
			msg.to.id = msg.chat_id or 0
			msg.to.title = data.title
		else
			msg.to.id = msg.chat_id or 0
			msg.to.title = false
		end
	end
	assert (tdbot_function ({ _ = "getChat", chat_id = data.chat_id }, get_gp, nil))
	function botifo_cb(arg, data)
		bot.id = data.id
		our_id = data.id
		if data.username then
			bot.username = data.username
		else
			bot.username = false
		end
		if data.first_name then
			bot.first_name = data.first_name
		end
		if data.last_name then
			bot.last_name = data.last_name
		else
			bot.last_name = false
		end
		if data.first_name and data.last_name then
			bot.print_name = data.first_name..' '..data.last_name
		else
			bot.print_name = data.first_name
		end
		if data.phone_number then
			bot.phone = data.phone_number
		else
			bot.phone = false
		end
	end
	assert (tdbot_function({ _ = 'getMe'}, botifo_cb, {chat_id=msg.chat_id}))
	function get_user(arg, data)
		if data.id then
			msg.from.id = data.id
		else
			msg.from.id = 0
		end
		if data.username then
			msg.from.username = data.username
		else
			msg.from.username = false
		end
		if data.first_name then
			msg.from.first_name = data.first_name
		end
		if data.last_name then
			msg.from.last_name = data.last_name
		else
			msg.from.last_name = false
		end
		if data.first_name and data.last_name then
			msg.from.print_name = data.first_name..' '..data.last_name
		else
			msg.from.print_name = data.first_name
		end
		if data.phone_number then
			msg.from.phone = data.phone_number
		else
			msg.from.phone = false
		end
		print_msg(msg)
		Core(msg)
		Msg_checks(msg)
		Mr_Mine(msg)
	end
	assert (tdbot_function ({ _ = "getUser", user_id = (data.sender_user_id or 0)}, get_user, nil))
end
local function Scharbytes(s, i)
	local byte    = string.byte
	i = i or 1
	if type(s) ~= "string" then
	end
	if type(i) ~= "number" then
	end
	local c = byte(s, i)
	if c > 0 and c <= 127 then
		return 1
	elseif c >= 194 and c <= 223 then
		local c2 = byte(s, i + 1)
		if not c2 then
		end
		if c2 < 128 or c2 > 191 then
		end
		return 2
	elseif c >= 224 and c <= 239 then
		local c2 = byte(s, i + 1)
		local c3 = byte(s, i + 2)
		if not c2 or not c3 then
		end
		if c == 224 and (c2 < 160 or c2 > 191) then
		elseif c == 237 and (c2 < 128 or c2 > 159) then
		elseif c2 < 128 or c2 > 191 then
		end
		if c3 < 128 or c3 > 191 then
		end
		return 3
	elseif c >= 240 and c <= 244 then
		local c2 = byte(s, i + 1)
		local c3 = byte(s, i + 2)
		local c4 = byte(s, i + 3)
		if not c2 or not c3 or not c4 then
		end
		if c == 240 and (c2 < 144 or c2 > 191) then
		elseif c == 244 and (c2 < 128 or c2 > 143) then
		elseif c2 < 128 or c2 > 191 then
		end
		if c3 < 128 or c3 > 191 then
		end
		if c4 < 128 or c4 > 191 then
		end
		return 4
	else
	end
end
function Slen(s)
	if type(s) ~= "string" then
		for k,v in pairs(s) do print('"',tostring(k),'"',tostring(v),'"') end
	end
	local pos = 1
	local bytes = string.len(s)
	local length = 0
	while pos <= bytes do
		length = length + 1
		pos = pos + Scharbytes(s, pos)
	end
	return length
end
function serialize_to_file(data, file, uglify)
	file = io.open(file, 'w+')
	local serialized
	if not uglify then
		serialized = serpent.block(data, {
		comment = false,
		name = '_'
		})
	else
		serialized = serpent.dump(data)
	end
	file:write(serialized)
	file:close()
end
function save_config( )
	serialize_to_file(Config, './data/Config.lua')
end
function string.random(length)
	local str = "";
	for i = 1, length do
		math.random(97, 122)
		str = str..string.char(math.random(97, 122));
	end
	return str;
end
function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
function string.trim(s)
	print("string.trim(s) is DEPRECATED use string:trim() instead")
	return s:gsub("^%s*(.-)%s*$", "%1")
end
function string:trim()
	return self:gsub("^%s*(.-)%s*$", "%1")
end
function get_http_file_name(url, headers)
	local file_name = url:match("[^%w]+([%.%w]+)$")
	file_name = file_name or url:match("[^%w]+(%w+)[^%w]+$")
	file_name = file_name or str:random(5)
	local content_type = headers["content-type"]
	local extension = nil
	if content_type then
		extension = mimetype.get_mime_extension(content_type)
	end
	if extension then
		file_name = file_name.."."..extension
	end
	local disposition = headers["content-disposition"]
	if disposition then
		file_name = disposition:match('filename=([^;]+)') or file_name
	end
	return file_name
end
function download_to_file(url, file_name)
	local respbody = {}
	local options = {
	url = url,
	sink = ltn12.sink.table(respbody),
	redirect = true
	}
	local response = nil
	
	if url:starts('https') then
		options.redirect = false
		response = {https.request(options)}
	else
		response = {http.request(options)}
	end
	
	local code = response[2]
	local headers = response[3]
	local status = response[4]
	
	if code ~= 200 then return nil end
	
	file_name = file_name or get_http_file_name(url, headers)
	
	local file_path = "data/photos/files/"..file_name
	file = io.open(file_path, "w+")
	file:write(table.concat(respbody))
	file:close()
	
	return file_path
end
function string:isempty()
	return self == nil or self == ''
end
function string:isblank()
	self = self:trim()
	return self:isempty()
end
function string.starts(String, Start)
	return Start == string.sub(String,1,string.len(Start))
end
function string:starts(text)
	return text == string.sub(self,1,string.len(text))
end
function unescape_html(str)
	local map = {
	["lt"]  = "<",
	["gt"]  = ">",
	["amp"] = "&",
	["quot"] = '"',
	["apos"] = "'"
	}
	new = string.gsub(str, '(&(#?x?)([%d%a]+);)', function(orig, n, s)
		var = map[s] or n == "#" and string.char(s)
		var = var or n == "#x" and string.char(tonumber(s,16))
		var = var or orig
		return var
	end)
	return new
end
function pairsByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function ()
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end
function run_command(str)
	local cmd = io.popen(str)
	local result = cmd:read('*all')
	cmd:close()
	return result
end
function run_bash(str)
	local cmd = io.popen(str)
	local result = cmd:read('*all')
	return result
end
function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	for filename in popen('ls -a "'..directory..'"'):lines() do
		i = i + 1
		t[i] = filename
	end
	return t
end
function plugins_names( )
	local files = {}
	for k, v in pairs(scandir("plugins")) do
		if (v:match(".lua$")) then
			table.insert(files, v)
		end
	end
	return files
end
function file_exists(name)
	local f = io.open(name,"r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end
function gp_type(chat_id)
	local gp_type = "pv"
	local id = tostring(chat_id)
	if id:match("^-100") then
		gp_type = "channel"
	elseif id:match("-") then
		gp_type = "chat"
	end
	return gp_type
end
function is_reply(msg)
	local var = false
	if msg.reply_to_message_id ~= 0 then
		var = true
	end
	return var
end
function is_supergroup(msg)
	chat_id = tostring(msg.chat_id)
	if chat_id:match('^-100') then
		if not msg.is_post then
			return true
		end
	else
		return false
	end
end
function is_channel(msg)
	chat_id = tostring(msg.chat_id)
	if chat_id:match('^-100') then
		if msg.is_post then
			return true
		else
			return false
		end
	end
end
function is_group(msg)
	chat_id = tostring(msg.chat_id)
	if chat_id:match('^-100') then
		return false
	elseif chat_id:match('^-') then
		return true
	else
		return false
	end
end
function is_private(msg)
	chat_id = tostring(msg.chat_id)
	if chat_id:match('^-') then
		return false
	else
		return true
	end
end
function check_markdown(text)
	str = text
	if str ~= nil then
		if str:match('_') then
			output = str:gsub('_',[[\_]])
		elseif str:match('*') then
			output = str:gsub('*','\\*')
		elseif str:match('`') then
			output = str:gsub('`','\\`')
		else
			output = str
		end
		return output
	end
end
function is_leader(msg)
	local var = false
	if is_leader1(tonumber(msg.sender_user_id)) then var = true end
	return var
end
function is_sudo(msg)
	local var = false
	if is_sudo1(tonumber(msg.sender_user_id)) then var = true end
	return var
end
function is_admin(msg)
	local var = false
	if is_admin1(tonumber(msg.sender_user_id)) then var = true end
	return var
end
function is_owner(msg)
	local var = false
	if is_owner1(tostring(msg.chat_id),tonumber(msg.sender_user_id)) then var = true end
	return var
end
function is_mod(msg)
	local var = false
	if is_mod1(tostring(msg.chat_id),tonumber(msg.sender_user_id)) then var = true end
	return var
end
function is_whitelist(chat_id, user_id)
	local var = false
	if is_mod1(chat_id, user_id) then var = true end
	if redis:sismember(RedisIndex.."Whitelist:"..chat_id,user_id) then var = true end
	return var
end
function is_leader1(user_id)
	local var = false
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_sudo1(user_id)
	local var = false
	for v,user in pairs(Config.sudo_users) do
		if user == user_id then
			var = true
		end
	end
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_admin1(user_id)
	local var = false
	local user = user_id
	for v,user in pairs(Config.admins) do
		if user[1] == user_id then
			var = true
		end
	end
	for v,user in pairs(Config.sudo_users) do
		if user == user_id then
			var = true
		end
	end
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_owner1(chat_id, user_id)
	local var = false
	if is_admin1(user_id) then var = true end
	if redis:sismember(RedisIndex.."Owners:"..chat_id,user_id) then var = true end
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_mod1(chat_id, user_id)
	local var = false
	if is_owner1(chat_id, user_id) then var = true end
	if redis:sismember(RedisIndex.."Mods:"..chat_id,user_id) then var = true end
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function warns_user_not_allowed(plugin, msg)
	if not user_allowed(plugin, msg) then
		return true
	else
		return false
	end
end
function user_allowed(plugin, msg)
	if plugin.privileged and not is_sudo(msg) then
		return false
	end
	return true
end
function is_banned(chat_id, user_id)
	local var = false
	if redis:sismember(RedisIndex.."Banned:"..chat_id,user_id) then var = true end
	return var
end
function is_silent_user(userid, chatid, msg, func)
	function check_silent(arg, data)
		local var = false
		if data.members then
			for k,v in pairs(data.members) do
			if(v.user_id == userid)then var = true end
		end
	end
	if func then
		func(msg, var)
	end
end
tdbot.getChannelMembers(chatid, 0, 100000, 'Restricted', check_silent)
end
function is_gbanned(user_id)
	local var = false
	if redis:sismember(RedisIndex.."GBanned",user_id) then var = true end
	return var
end
function is_filter(msg, text)
	local var = false
	local filter = redis:hkeys(RedisIndex..'filterlist:'..msg.to.id)
	if filter then
		for i = 1, #filter do
			if string.match(text, filter[i]) then
				var = true
			end
		end
	end
	return var
end
function kick_user(user_id, chat_id)
	if not tonumber(user_id) then
		return false
	end
	tdbot.changeChatMemberStatus(chat_id, user_id, 'Banned', {0}, dl_cb, nil)
end
function del_msg(chat_id, message_ids)
	local msgid = {[0] = message_ids}
	tdbot.deleteMessages(chat_id, msgid, true, dl_cb, nil)
end
function channel_unblock(chat_id, user_id)
	tdbot.changeChatMemberStatus(chat_id, user_id, 'Left', dl_cb, nil)
end
function channel_set_admin(chat_id, user_id)
	tdbot.changeChatMemberStatus(chat_id, user_id, 'Administrators', {1, 1, 1, 1, 1, 1, 1, 1, 0}, dl_cb, nil)
end
function channel_demote(chat_id, user_id)
	tdbot.changeChatMemberStatus(chat_id, user_id, 'Restriced', {1, 0, 1, 1, 1, 1}, dl_cb, nil)
end
function silent_user(chat_id, user_id)
	tdbot.changeChatMemberStatus(chat_id, user_id, 'Restricted', {1, 0, 0, 0, 0, 0}, dl_cb, nil)
end
function unsilent_user(chat_id, user_id)
	tdbot.changeChatMemberStatus(chat_id, user_id, 'Restricted', {1, 0, 1, 1, 1, 1}, dl_cb, nil)
end
function file_dl(file_id)
	tdbot.downloadFile(file_id, 32, dl_cb, nil)
end
function ReplySet(msg ,Cmd)
	if msg.reply_id then
		tdbot_function ({
		_ = "getMessage",
		chat_id = msg.to.id,
		message_id = msg.reply_id
		}, action_by_reply, {chat_id=msg.to.id,cmd=Cmd})
	end
end
function UseridSet(msg, Matches ,Cmd)
	if Matches and string.match(Matches, '^%d+$') then
		tdbot_function ({
		_ = "getUser",
		user_id = Matches,
		}, action_by_id, {chat_id=msg.to.id,user_id=Matches,cmd=Cmd})
	end
	if Matches and not string.match(Matches, '^%d+$') then
		tdbot_function ({
		_ = "searchPublicChat",
		username = Matches
		}, action_by_username, {chat_id=msg.to.id,username=Matches,cmd=Cmd})
	end
end
function action_by_reply1(arg, data)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	local cmd = arg.cmd
	if not tonumber(data.sender_user_id) then return false end
	if data.sender_user_id then
		if cmd == "id" then
			local function id_cb(arg, data)
				if data.first_name then
					user_name = check_markdown(data.first_name)
				end
				text = Source_Start.."*نام کاربری :* @"..check_markdown(data.username).."\n"..Source_Start.."*نام :* "..user_name.."\n"..Source_Start.."*ایدی :* `"..data.id.."`"
				return tdbot.sendMessage(arg.chat_id, "", 0, text, 0, "md")
			end
			tdbot_function ({
			_ = "getUser",
			user_id = data.sender_user_id
			}, id_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
		end
	end
end
function StartBot(bot_user_id, chat_id, parameter)
	assert (tdbot_function ({_ = 'sendBotStartMessage',bot_user_id = bot_user_id,chat_id = chat_id,parameter = tostring(parameter)},  dl_cb, nil))
end
function Mr_Mine(msg)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	local chat = msg.to.id
	local user = msg.from.id
	local checkmod = true
	if msg.to.type ~= 'pv' then
		local gpst = redis:get(RedisIndex.."CheckBot:"..msg.to.id)
		local chex = redis:get(RedisIndex..'CheckExpire::'..msg.to.id)
		local exd = redis:get(RedisIndex..'ExpireDate:'..msg.to.id)
		if gpst and not chex and msg.from.id ~= SUDO and not is_sudo(msg) then
			redis:set(RedisIndex..'CheckExpire::'..msg.to.id,true)
			redis:set(RedisIndex..'ExpireDate:'..msg.to.id,true)
			redis:setex(RedisIndex..'ExpireDate:'..msg.to.id, 86400, true)
			tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'*گروه به مدت 1 روز شارژ شد. لطفا با سودو برای شارژ بیشتر تماس بگیرید.*\n`سودو ربات :` '..check_markdown(sudo_username)..EndMsg, 1, 'md')
		end
		if chex and not exd and msg.from.id ~= SUDO and not is_sudo(msg) then
			local text1 = Source_Start..'شارژ این گروه به اتمام رسید \n\nID:  <code>'..msg.to.id..'</code>\n\nدر صورتی که میخواهید ربات این گروه را ترک کند از دستور زیر استفاده کنید\n\n/leave '..msg.to.id..'\nبرای جوین دادن توی این گروه میتونی از دستور زیر استفاده کنی:\n/jointo '..msg.to.id..'\n_________________\nدر صورتی که میخواهید گروه رو دوباره شارژ کنید میتوانید از کد های زیر استفاده کنید...\n\n<b>برای شارژ 1 ماهه:</b>\n/plan 1 '..msg.to.id..'\n\n<b>برای شارژ 3 ماهه:</b>\n/plan 2 '..msg.to.id..'\n\n<b>برای شارژ نامحدود:</b>\n/plan 3 '..msg.to.id
			local text2 = Source_Start..'*شارژ این گروه به پایان رسید. به دلیل عدم شارژ مجدد، گروه از لیست ربات حذف و ربات از گروه خارج میشود*'..EndMsg..'\n`سودو ربات :`'..check_markdown(sudo_username)
			tdbot.sendMessage(gp_sudo, 0, 1, text1, 1, 'html')
			tdbot.sendMessage(msg.to.id, 0, 1, text2, 1, 'md')
			botrem(msg)
		else
			local expiretime = redis:ttl(RedisIndex..'ExpireDate:'..msg.to.id)
			local day = (expiretime / 86400)
			if tonumber(day) > 0.208 and not is_sudo(msg) and is_mod(msg) then
				warning(msg)
			end
		end
	end
	if msg.to.type == 'channel' and msg.content.text and redis:hget(RedisIndex.."CodeGiftt:", msg.content.text) then
		local b = redis:ttl(RedisIndex.."CodeGiftCharge:"..msg.content.text)
		local expire = math.floor(b / 86400 ) + 1
		local c = redis:ttl(RedisIndex..'ExpireDate:'..msg.to.id)
		local extime = math.floor(c / 86400 ) + 1
		redis:setex(RedisIndex..'ExpireDate:'..msg.to.id, tonumber(extime * 86400) + tonumber(expire * 86400), true)
		redis:del(RedisIndex.."Codegift:"..msg.to.id)
		redis:srem(RedisIndex.."CodeGift:" , msg.content.text)
		redis:hdel(RedisIndex.."CodeGiftt:", msg.content.text)
		local expire_date = ''
		local expi = redis:ttl(RedisIndex..'ExpireDate:'..msg.to.id)
		if expi == -1 then
			expire_date = 'نامحدود!'
		else
			local day = math.floor(expi / 86400) + 1
			expire_date = day..' روز'
		end
		local text = Source_Start.."`کدهدیه :`\n"..msg.content.text.."\n`استفاده شد توسط :`\n*مشخصات کاربر :*\n`꧁` @"..check_markdown(msg.from.username or '').." | "..check_markdown(msg.from.first_name).." `꧂`\n*ایدی گروه :*\n"..msg.chat_id.."\n*میزان شارژ هدیه :* `"..expire.."` *روز\nشارژ جدید گروه کاربر :* `"..expire_date.."`"
		tdbot.sendMessage(gp_sudo, msg.id, 1, text, 1, 'md')
		local text2 = Source_Start..'`انجام شد !`\n`به گروه شما` *'..expire..'* `روز شارژ هدیه اضافه شد`'..EndMsg
		tdbot.sendMessage(msg.chat_id, msg.id, 1, text2, 1, 'md')
	end
	if redis:get(RedisIndex.."atolct2"..msg.to.id) or redis:get(RedisIndex.."atolct2"..msg.to.id) then
		local time = os.date("%H%M")
		local time2 = redis:get(RedisIndex.."atolct1"..msg.to.id)
		time2 = time2.gsub(time2,":","")
		local time3 = redis:get(RedisIndex.."atolct2"..msg.to.id)
		time3 = time3.gsub(time3,":","")
		if tonumber(time3) < tonumber(time2) then
			if tonumber(time) <= 2359 and tonumber(time) >= tonumber(time2) then
				if not redis:get(RedisIndex.."lc_ato:"..msg.to.id) then
					redis:set(RedisIndex.."lc_ato:"..msg.to.id,true)
					tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'`قفل خودکار ربات فعال شد`\n`گروه تا ساعت` *'..redis:get(RedisIndex.."atolct2"..msg.to.id)..'* `تعطیل میباشد.`'..EndMsg, 1, 'md')
				end
			elseif tonumber(time) >= 0000 and tonumber(time) < tonumber(time3) then
				if not redis:get(RedisIndex.."lc_ato:"..msg.to.id) then
					tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'`قفل خودکار ربات فعال شد`\n`گروه تا ساعت` *'..redis:get(RedisIndex.."atolct2"..msg.to.id)..'* `تعطیل میباشد.`'..EndMsg, 1, 'md')
					redis:set(RedisIndex.."lc_ato:"..msg.to.id,true)
				end
			else
				if redis:get(RedisIndex.."lc_ato:"..msg.to.id) then
					redis:del(RedisIndex.."lc_ato:"..msg.to.id, true)
				end
			end
		elseif tonumber(time3) > tonumber(time2) then
			if tonumber(time) >= tonumber(time2) and tonumber(time) < tonumber(time3) then
				if not redis:get(RedisIndex.."lc_ato:"..msg.to.id) then
					tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'`قفل خودکار ربات فعال شد`\n`گروه تا ساعت` *'..redis:get(RedisIndex.."atolct2"..msg.to.id)..'* `تعطیل میباشد.`'..EndMsg, 1, 'md')
					redis:set(RedisIndex.."lc_ato:"..msg.to.id,true)
				end
			else
				if redis:get(RedisIndex.."lc_ato:"..msg.to.id) then
					redis:del(RedisIndex.."lc_ato:"..msg.to.id, true)
				end
			end
		end
	end
	if redis:get(RedisIndex.."lc_ato:"..msg.to.id) then
		local is_channel = msg.to.type == "channel"
		local is_chat = msg.to.type == "chat"
		if not is_mod(msg) then
			if is_channel then
				del_msg(msg.to.id, tonumber(msg.id))
			elseif is_chat then
				kick_user(msg.sender_user_id, msg.to.id)
			end
		end
	end
	if gp_type(msg.chat_id) == "pv" and   msg.content.text and not is_admin(msg) then
		local chkmonshi = redis:get(RedisIndex..msg.from.id..'chkusermonshi')
		local hash = ('bot:pm')
		local pm = redis:get(RedisIndex..hash)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if not chkmonshi and pm then
			redis:set(RedisIndex..msg.from.id..'chkusermonshi', true)
			redis:setex(RedisIndex..msg.from.id..'chkusermonshi', 86400, true)
			tdbot.sendMessage(msg.chat_id , msg.id, 1, check_markdown(pm), 0, 'md')
			tdbot.sendMessage(gp_sudo , 0, 1,Source_Start.."`شخصی وارد پیوی ربات شد :`\n*پیام :*\n"..check_markdown(msg.content.text).."\n*آیدی فرستنده :*\n`"..msg.sender_user_id.."`"..EndMsg, 0, 'md')
		else
			tdbot.sendMessage(gp_sudo , 0, 1,Source_Start.."`شخصی وارد پیوی ربات شد :`\n*پیام :*\n"..check_markdown(msg.content.text).."\n*آیدی فرستنده :*\n`"..msg.sender_user_id.."`"..EndMsg, 0, 'md')
		end
	end
	if not is_mod(msg) then
		local add_lock = redis:hget(RedisIndex..'addmeminv', msg.to.id)
		if add_lock == 'on' then
			local chsh = 'addpm'..msg.to.id
			local hsh = redis:get(RedisIndex..chsh)
			local chkpm = redis:get(RedisIndex..msg.from.id..'chkuserpm'..msg.to.id)
			if msg.from.username ~= '' then
				username = '@'..check_markdown(msg.from.username)
			else
				username = check_markdown(msg.from.print_name)
			end
			local setadd = redis:hget(RedisIndex..'addmemset', msg.to.id) or 10
			if msg.adduser then
				tdbot.getUser(msg.content.member_user_ids[0], function(TM, BD)
					if BD.type._ == 'userTypeBot' then
						if not hsh then
							tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'*کاربر* `'..msg.from.id..'` - '..username..' *شما یک ربات به گروه اضافه کردید لطفا یک کاربر اضافه کنید*'..EndMsg, 1, 'md')
						end
						return
					end
					if #msg.content.member_user_ids > 0 then
						if not hsh then
							tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'*کاربر* `'..msg.from.id..'` - '..username..' *شما تعداد* `'..(#msg.content.member_user_ids + 1)..'` *کاربر را اضافه کردید اما فقط یک کاربر برای شما ذخیره شد لطفا کاربران رو تک به تک اضافه کنید تا محدودیت برای شما برداشته شود*'..EndMsg, 1, 'md')
						end
					end
					local chash = msg.content.member_user_ids[0]..'chkinvusr'..msg.from.id..'chat'..msg.to.id
					local chk = redis:get(RedisIndex..chash)
					if not chk then
						redis:set(RedisIndex..chash, true)
						local achash = 'addusercount'..msg.from.id
						local count = redis:hget(RedisIndex..achash, msg.to.id) or 0
						redis:hset(RedisIndex..achash, msg.to.id, (tonumber(count) + 1))
						local permit = redis:hget(RedisIndex..achash, msg.to.id)
						if tonumber(permit) < tonumber(setadd) then
							local less = tonumber(setadd) - tonumber(permit)
							if not hsh then
								tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'*کاربر* `'..msg.from.id..'` - '..username..' *شما تعداد* `'..permit..'` *کاربر را به این گروه اضافه کردید باید* `'..less..'` *کاربر دیگر برای رفع محدودیت چت اضافه کنید*'..EndMsg, 1, 'md')
							end
						elseif tonumber(permit) == tonumber(setadd) then
							if not hsh then
								tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'*کاربر* `'..msg.from.id..'` - '..username..' *شما اکنون میتوانید پیام ارسال کنید*'..EndMsg, 1, 'md')
							end
						end
					else
						if not hsh then
							tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'*کاربر* `'..msg.from.id..'` - '..username..' *شما قبلا این کاربر را به گروه اضافه کرده اید*'..EndMsg, 1, 'md')
						end
					end
					end, nil)
				end
				local permit = redis:hget(RedisIndex..'addusercount'..msg.from.id, msg.to.id) or 0
				if tonumber(permit) < tonumber(setadd) then
					tdbot.deleteMessages(msg.to.id, {[0] = msg.id}, true, dl_cb, nil)
					if not chkpm then
						redis:set(RedisIndex..msg.from.id..'chkuserpm'..msg.to.id, true)
						tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'*کاربر* `'..msg.from.id..'` - '..username..' *شما باید* `'..setadd..'` *کاربر دیگر رابه به گروه دعوت کنید تا بتوانید پیام ارسال کنید*'..EndMsg, 1, 'md')
					end
					return
				end
			end
		end
		if msg.to.type ~= 'pv' then
			chat = msg.to.id
			user = msg.from.id
			function check_newmember(arg, data)
				if redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
					lock_bots = redis:get(RedisIndex..'lock_bots:'..msg.chat_id)
				end
				if data.type._ == "userTypeBot" then
					if not is_owner(arg.msg) and lock_bots == 'Enable' then
						kick_user(data.id, arg.chat_id)
						sleep(0.5)
						local function GetBots(arg, m)
							if m.members then
								for k,v in pairs (m.members) do
									if not is_mod1(msg.to.id, v.user_id) then
										kick_user(v.user_id, msg.to.id)
									end
								end
							end
						end
						for i = 1, 5 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Bots', GetBots, {msg=msg})
						end
					elseif not is_owner(arg.msg) and lock_bots == 'Pro' then
						kick_user(data.id, arg.chat_id)
						tdbot.sendMention(chat,user, data.id,Source_Start..'کاربر '..user..' اضافه کردن ربات ممنوع است ربات '..data.id..' - '..data.username..' و شما از گروه ممنوع شدید'..EndMsg,8,string.len(user))
						kick_user(user, chat)
						sleep(0.5)
						local function GetBots(arg, m)
							if m.members then
								for k,v in pairs (m.members) do
									if not is_mod1(msg.to.id, v.user_id) then
										kick_user(v.user_id, msg.to.id)
									end
								end
							end
						end
						for i = 1, 5 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Bots', GetBots, {msg=msg})
						end
					end
				end
				if data.username then
					user_name = '@'..check_markdown(data.username)
				else
					user_name = check_markdown(data.first_name)
				end
				if is_banned(data.id, arg.chat_id) then
					tdbot.sendMessage(arg.chat_id, arg.msg_id, 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه (مسدود) است*"..EndMsg, 0, "md")
					kick_user(data.id, arg.chat_id)
				end
				if is_gbanned(data.id) then
					tdbot.sendMessage(arg.chat_id, arg.msg_id, 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از تمام گروه های ربات (مسدود) است*"..EndMsg, 0, "md")
					kick_user(data.id, arg.chat_id)
				end
			end
			if msg.adduser then
				assert(tdbot_function ({
				_ = "getUser",
				user_id = msg.adduser
				}, check_newmember, {chat_id=chat,msg_id=msg.id,user_id=user,msg=msg}))
			end
			if msg.joinuser then
				assert(tdbot_function ({
				_ = "getUser",
				user_id = msg.joinuser
				}, check_newmember, {chat_id=chat,msg_id=msg.id,user_id=user,msg=msg}))
			end
		end
		local function welcome_cb(arg, data)
			local url , res = http.request('http://api.beyond-dev.ir/time/')
			if res ~= 200 then return "No connection" end
			local jdat = json:decode(url)
			if redis:get(RedisIndex..'setwelcome:'..msg.chat_id) then
				welcome = redis:get(RedisIndex..'setwelcome:'..msg.chat_id)
			else
				welcome = Source_Start.."`به گروه خوشآمدید`"..EndMsg
			end
			if redis:get(RedisIndex..msg.to.id..'rules') then
				rules = redis:get(RedisIndex..msg.to.id..'rules')
			else
				rules = Source_Start.."`قوانین برای گروه ثبت نشده است`"..EndMsg
			end
			if data.username then
				user_name = "@"..check_markdown(data.username)
			else
				user_name = ""
			end
			local welcome = welcome:gsub("{rules}", rules)
			local welcome = welcome:gsub("{name}", check_markdown(data.first_name..' '..(data.last_name or '')))
			local welcome = welcome:gsub("{username}", user_name)
			local welcome = welcome:gsub("{time}", jdat.ENtime)
			local welcome = welcome:gsub("{date}", jdat.ENdate)
			local welcome = welcome:gsub("{timefa}", jdat.FAtime)
			local welcome = welcome:gsub("{datefa}", jdat.FAdate)
			local welcome = welcome:gsub("{gpname}", arg.gp_name)
			tdbot.sendMessage(arg.chat_id, arg.msg_id, 0, welcome, 0, "md")
		end
		if redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
			if msg.adduser then
				welcome = redis:get(RedisIndex..'welcome:'..msg.chat_id)
				if welcome == 'Enable' then
					tdbot.getUser(msg.adduser, welcome_cb, {chat_id=chat,msg_id=msg.id,gp_name=msg.to.title})
				else
					return false
				end
			end
			if msg.joinuser then
				welcome = redis:get(RedisIndex..'welcome:'..msg.chat_id)
				if welcome == 'Enable' then
					tdbot.getUser(msg.sender_user_id, welcome_cb, {chat_id=chat,msg_id=msg.id,gp_name=msg.to.title})
				else
					return false
				end
			end
		end
		if tonumber(msg.sender_user_id) ~= 0 then
			if msg.from.username then
				user_name = '@'..msg.from.username
			else
				user_name = msg.from.print_name
			end
			redis:set(RedisIndex..'user_name:'..msg.from.id, user_name)
		end
	end
	function exi_files(cpath)
		local files = {}
		local pth = cpath
		for k, v in pairs(scandir(pth)) do
			table.insert(files, v)
		end
		return files
	end
	function file_exi(name, cpath)
		for k,v in pairs(exi_files(cpath)) do
			if name == v then
				return true
			end
		end
		return false
	end
	function run_bash(str)
		local cmd = io.popen(str)
		local result = cmd:read('*all')
		return result
	end
	function index_function(user_id)
		for k,v in pairs(Config.admins) do
			if user_id == v[1] then
				print(k)
				return k
			end
		end
		return false
	end
	function getindex(t,id)
		for i,v in pairs(t) do
			if v == id then
				return i
			end
		end
		return nil
	end
	function already_sudo(user_id)
		for k,v in pairs(Config.sudo_users) do
			if user_id == v then
				return k
			end
		end
		return false
	end
	function exi_file()
		local files = {}
		local pth = tcpath..'/files/documents'
		for k, v in pairs(scandir(pth)) do
			if (v:match('.lua$')) then
				table.insert(files, v)
			end
		end
		return files
	end
	function pl_exi(name)
		for k,v in pairs(exi_file()) do
			if name == v then
				return true
			end
		end
		return false
	end
	function sudolist(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		local sudo_users = Config.sudo_users
		text = Source_Start.."*لیست سودو های ربات :*\n"
		for i=1,#sudo_users do
			text = text..i.." - `"..sudo_users[i].."`\n"
		end
		tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
	end
	function adminlist(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		local sudo_users = Config.sudo_users
		text = Source_Start.."*لیست ادمین های ربات :*\n"
		local compare = text
		local i = 1
		for v,user in pairs(Config.admins) do
			text = text..i..'- '..( user[2] or '' )..' ➣ `('..user[1]..')`\n'
			i = i +1
		end
		if compare == text then
			text = Source_Start..'`ادمینی برای ربات انتخاب نشده`'..EndMsg
		end
		tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
	end
	function chat_list(msg)
		local list = redis:smembers(RedisIndex..'Group')
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		local message = Source_Start..'لیست گروه های ربات :\n\n'
		if #list == 0 then
			message = Source_Start..'لیست گروهها خالی میباشد'..EndMsg
		end
		for k,v in pairs(list) do
			local check_time = redis:ttl(RedisIndex..'ExpireDate:'..v)
			year = math.floor(check_time / 31536000)
			byear = check_time % 31536000
			month = math.floor(byear / 2592000)
			bmonth = byear % 2592000
			day = math.floor(bmonth / 86400)
			bday = bmonth % 86400
			hours = math.floor( bday / 3600)
			bhours = bday % 3600
			min = math.floor(bhours / 60)
			sec = math.floor(bhours % 60)
			if check_time == -1 then
				remained_expire = 'گروه به صورت نامحدود شارژ میباشد!'
			elseif tonumber(check_time) > 1 and check_time < 60 then
				remained_expire = 'گروه به مدت '..sec..' ثانیه شارژ میباشد'
			elseif tonumber(check_time) > 60 and check_time < 3600 then
				remained_expire = 'گروه به مدت '..min..' دقیقه و '..sec..' ثانیه شارژ میباشد'
			elseif tonumber(check_time) > 3600 and tonumber(check_time) < 86400 then
				remained_expire = 'گروه به مدت '..hours..' ساعت و '..min..' دقیقه و '..sec..' ثانیه شارژ میباشد'
			elseif tonumber(check_time) > 86400 and tonumber(check_time) < 2592000 then
				remained_expire = 'گروه به مدت '..day..' روز و '..hours..' ساعت و '..min..' دقیقه و '..sec..' ثانیه شارژ میباشد'
			elseif tonumber(check_time) > 2592000 and tonumber(check_time) < 31536000 then
				remained_expire = 'گروه به مدت '..month..' ماه '..day..' روز و '..hours..' ساعت و '..min..' دقیقه و '..sec..' ثانیه شارژ میباشد'
			elseif tonumber(check_time) > 31536000 then
				remained_expire = 'گروه به مدت '..year..' سال '..month..' ماه '..day..' روز و '..hours..' ساعت و '..min..' دقیقه و '..sec..' ثانیه شارژ میباشد'
			end
			local GroupsName = redis:get(RedisIndex..'Gpnameset'..v)
			message = message..k..'-'..Source_Start..'نام گروه : '..GroupsName..'\n'..Source_Start..'آیدی : ' ..v.. '\n'..Source_Start..'اعتبار : '..remained_expire..'\n_______________\n'
		end
		local file = io.open("./data/Gplist.txt", "w")
		file:write(message)
		file:close()
		MaT = Source_Start.."لیست گروه های ربات"..EndMsg
		tdbot.sendDocument(msg.to.id, "./data/Gplist.txt", MaT, nil, msg.id, 0, 1, nil, dl_cb, nil)
	end
	function botrem(msg)
		if redis:get(RedisIndex..'CheckExpire::'..msg.to.id) then
			redis:del(RedisIndex..'CheckExpire::'..msg.to.id)
		end
		if redis:get(RedisIndex..'ExpireDate:'..msg.to.id) then
			redis:del(RedisIndex..'ExpireDate:'..msg.to.id)
		end
		redis:srem(RedisIndex.."Group" ,msg.to.id)
		redis:del(RedisIndex.."Gpnameset"..msg.to.id)
		redis:del(RedisIndex.."CheckBot:"..msg.to.id)
		redis:del(RedisIndex.."Whitelist:"..msg.to.id)
		redis:del(RedisIndex.."Banned:"..msg.to.id)
		redis:del(RedisIndex.."Owners:"..msg.to.id)
		redis:del(RedisIndex.."Mods:"..msg.to.id)
		redis:del(RedisIndex..'filterlist:'..msg.to.id)
		redis:del(RedisIndex..msg.to.id..'rules')
		redis:del(RedisIndex..'setwelcome:'..msg.chat_id)
		redis:del(RedisIndex..'lock_link:'..msg.chat_id)
		redis:del(RedisIndex..'lock_join:'..msg.chat_id)
		redis:del(RedisIndex..'lock_tag:'..msg.chat_id)
		redis:del(RedisIndex..'lock_username:'..msg.chat_id)
		redis:del(RedisIndex..'lock_pin:'..msg.chat_id)
		redis:del(RedisIndex..'lock_arabic:'..msg.chat_id)
		redis:del(RedisIndex..'lock_mention:'..msg.chat_id)
		redis:del(RedisIndex..'lock_edit:'..msg.chat_id)
		redis:del(RedisIndex..'lock_spam:'..msg.chat_id)
		redis:del(RedisIndex..'lock_flood:'..msg.chat_id)
		redis:del(RedisIndex..'lock_markdown:'..msg.chat_id)
		redis:del(RedisIndex..'lock_webpage:'..msg.chat_id)
		redis:del(RedisIndex..'welcome:'..msg.chat_id)
		redis:del(RedisIndex..'views:'..msg.chat_id)
		redis:del(RedisIndex..'lock_bots:'..msg.chat_id)
		redis:del(RedisIndex..'mute_all:'..msg.chat_id)
		redis:del(RedisIndex..'mute_gif:'..msg.chat_id)
		redis:del(RedisIndex..'mute_photo:'..msg.chat_id)
		redis:del(RedisIndex..'mute_sticker:'..msg.chat_id)
		redis:del(RedisIndex..'mute_contact:'..msg.chat_id)
		redis:del(RedisIndex..'mute_inline:'..msg.chat_id)
		redis:del(RedisIndex..'mute_game:'..msg.chat_id)
		redis:del(RedisIndex..'mute_text:'..msg.chat_id)
		redis:del(RedisIndex..'mute_keyboard:'..msg.chat_id)
		redis:del(RedisIndex..'mute_forward:'..msg.chat_id)
		redis:del(RedisIndex..'mute_location:'..msg.chat_id)
		redis:del(RedisIndex..'mute_document:'..msg.chat_id)
		redis:del(RedisIndex..'mute_voice:'..msg.chat_id)
		redis:del(RedisIndex..'mute_audio:'..msg.chat_id)
		redis:del(RedisIndex..'mute_video:'..msg.chat_id)
		redis:del(RedisIndex..'mute_video_note:'..msg.chat_id)
		redis:del(RedisIndex..'mute_tgservice:'..msg.chat_id)
		redis:del(RedisIndex..msg.to.id..'set_char')
		redis:del(RedisIndex..msg.to.id..'num_msg_max')
		redis:del(RedisIndex..msg.to.id..'time_check')
		tdbot.changeChatMemberStatus(msg.to.id, our_id, 'Left', dl_cb, nil)
	end
	function warning(msg)
		local expiretime = redis:ttl(RedisIndex..'ExpireDate:'..msg.to.id)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if expiretime == -1 then
			return
		else
			local d = math.floor(expiretime / 86400) + 1
			if tonumber(d) == 1 and not is_sudo(msg) and is_mod(msg) then
				tdbot.sendMessage(msg.to.id, 0, 1, Source_Start..'`از شارژ گروه 1 روز باقی مانده\n'..Source_Start..'برای شارژ مجدد با سودو ربات تماس بگیرید`'..EndMsg..'\n`سودو ربات :` '..check_markdown(sudo_username), 1, 'md')
			end
		end
	end
	function action_by_reply(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		cmd = arg.cmd
		if not tonumber(data.sender_user_id) then return false end
		if data.sender_user_id then
			if cmd == "warn" then
				function warn_cb(arg, data)
					msg = arg.msg
					hashwarn = arg.chat_id..':warn'
					warnhash = redis:hget(RedisIndex..hashwarn, data.id) or 1
					max_warn = tonumber(redis:get(RedisIndex..'max_warn:'..arg.chat_id) or 5)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if tonumber(data.id) == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم به خودم اخطار دهم*"..EndMsg, 0, "md")
					end
					if is_mod1(arg.chat_id, data.id) and not is_admin1(data.id)then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید به مدیران،صاحبان گروه، و ادمین های ربات اخطار دهید*"..EndMsg, 0, "md")
					end
					if is_admin1(data.id)then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید به ادمین های ربات اخطار دهید*"..EndMsg, 0, "md")
					end
					if tonumber(warnhash) == tonumber(max_warn) then
						kick_user(data.id, arg.chat_id)
						redis:hdel(RedisIndex..hashwarn, data.id, '0')
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به دلیل دریافت اخطار بیش از حد اخراج شد"..EndMsg.."\nتعداد اخطار ها :* `"..warnhash.."/"..max_warn.."`", 0, "md")
					else
						redis:hset(RedisIndex..hashwarn, data.id, tonumber(warnhash) + 1)
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *شما یک اخطار دریافت کردید"..EndMsg.."\nتعداد اخطار های شما :* `"..warnhash.."/"..max_warn.."`", 0, "md")
					end
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, warn_cb, {chat_id=data.chat_id,user_id=data.sender_user_id,msg=arg.msg})
			end
			if cmd == "unwarn" then
				function unwarn_cb(arg, data)
					hashwarn = arg.chat_id..':warn'
					warnhash = redis:hget(RedisIndex..hashwarn, data.id) or 1
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not redis:hget(RedisIndex..hashwarn, data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *هیچ اخطاری دریافت نکرده*"..EndMsg, 0, "md")
					else
						redis:hdel(RedisIndex..hashwarn, data.id, '0')
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*تمامی اخطار های کاربر* `"..data.id.."` - "..user_name.." *پاک شدند*"..EndMsg, 0, "md")
					end
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, unwarn_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "setwhitelist" then
				function setwhitelist_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل در لیست ویژه بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به لیست ویژه اضافه شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, setwhitelist_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "remwhitelist" then
				function remwhitelist_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل در لیست ویژه نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از لیست ویژه حذف شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, remwhitelist_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "setowner" then
				function owner_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Owners:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مالک گروه بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Owners:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام مالک گروه منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, owner_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "promote" then
				function promote_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Mods:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مدیر گروه بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Mods:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام مدیر گروه منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, promote_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "remowner" then
				function rem_owner_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Owners:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مالک گروه نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Owners:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام مالک گروه برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, rem_owner_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "demote" then
				function demote_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Mods:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مدیر گروه نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Mods:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام مدیر گروه برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, demote_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "ban" then
				function ban_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از گروه محروم کنم*"..EndMsg, 0, "md")
					end
					if is_mod1(arg.chat_id, data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید مدیران،صاحبان گروه، و ادمین های ربات رو از گروه محروم کنید*"..EndMsg, 0, "md")
					end
					local list = redis:sismember(RedisIndex.."Banned:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه محروم بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Banned:"..arg.chat_id,data.id)
					kick_user(data.id, arg.chat_id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه محروم شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, ban_cb, {chat_id=data.chat_id,user_id=data.sender_user_id}))
			end
			if cmd == "unban" then
				function unban_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Banned:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه محروم نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Banned:"..arg.chat_id,data.id)
					channel_unblock(arg.chat_id, data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از محرومیت گروه خارج شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, unban_cb, {chat_id=data.chat_id,user_id=data.sender_user_id}))
			end
			if cmd == "silent" then
				function silent_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم توانایی چت کردن رو از خودم بگیرم*"..EndMsg, 0, "md")
					end
					if is_mod1(arg.chat_id, data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه، و ادمین های ربات بگیرید*"..EndMsg, 0, "md")
					end
					local function check_silent(msg, is_silent)
						local user_name = msg.user_name
						arg = msg.arg
						if is_silent then
							return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل توانایی چت کردن رو نداشت*"..EndMsg, 0, "md")
						end
						silent_user(arg.chat_id, data.id)
						redis:sadd(RedisIndex.."Silentlist:"..arg.chat_id,data.id)
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *توانایی چت کردن رو از دست داد*"..EndMsg, 0, "md")
					end
					is_silent_user(data.id, arg.chat_id, {arg=arg, user_name=user_name,id=data.id}, check_silent)
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, silent_cb, {chat_id=data.chat_id,user_id=data.sender_user_id}))
			end
			if cmd == "unsilent" then
				local function unsilent_cb(arg, data)
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local function check_silent(msg, is_silent)
						local user_name = msg.user_name
						arg = msg.arg
						if not is_silent then
							return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل توانایی چت کردن را داشت*"..EndMsg, 0, "md")
						end
						unsilent_user(arg.chat_id, data.id)
						redis:srem(RedisIndex.."Silentlist:"..arg.chat_id,data.id)
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *توانایی چت کردن رو به دست آورد*"..EndMsg, 0, "md")
					end
					is_silent_user(data.id, arg.chat_id, {arg=arg, user_name=user_name,id=data.id}, check_silent)
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, unsilent_cb, {chat_id=data.chat_id,user_id=data.sender_user_id}))
			end
			if cmd == "banall" then
				function gban_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از تمام گروه های ربات محروم کنم*"..EndMsg, 0, "md")
					end
					if is_admin1(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید ادمین های ربات رو از تمامی گروه های ربات محروم کنید*"..EndMsg, 0, "md")
					end
					if is_gbanned(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه های ربات محروم بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."GBanned",data.id)
					kick_user(data.id, arg.chat_id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از تمام گروه های ربات محروم شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, gban_cb, {chat_id=data.chat_id,user_id=data.sender_user_id}))
			end
			if cmd == "unbanall" then
				function ungban_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not is_gbanned(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه های ربات محروم نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."GBanned",data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از محرومیت گروه های ربات خارج شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, ungban_cb, {chat_id=data.chat_id,user_id=data.sender_user_id}))
			end
			if cmd == "kick" then
				if data.sender_user_id == our_id then
					return tdbot.sendMessage(data.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از گروه اخراج کنم کنم*"..EndMsg, 0, "md")
				elseif is_mod1(data.chat_id, data.sender_user_id) then
					return tdbot.sendMessage(data.chat_id, "", 0, Source_Start.."*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو اخراج کنید*"..EndMsg, 0, "md")
				else
					kick_user(data.sender_user_id, data.chat_id)
					sleep(1)
					channel_unblock(data.chat_id, data.sender_user_id)
				end
			end
			if cmd == "delall" then
				if is_mod1(data.chat_id, data.sender_user_id) then
					return tdbot.sendMessage(data.chat_id, "", 0, Source_Start.."*شما نمیتوانید پیام های مدیران،صاحبان گروه و ادمین های ربات رو پاک کنید*"..EndMsg, 0, "md")
				else
					tdbot.deleteMessagesFromUser(data.chat_id, data.sender_user_id, dl_cb, nil)
					tdbot.sendMention(data.chat_id,data.sender_user_id, data.id,Source_Start..'تمام پیام های '..data.sender_user_id..' پاک شد'..EndMsg,16,string.len(data.sender_user_id))
				end
			end
			if cmd == "adminprom" then
				function adminprom_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if is_admin1(tonumber(data.id)) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل ادمین ربات بود*"..EndMsg, 0, "md")
					end
					table.insert(Config.admins, {tonumber(data.id), user_name})
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام ادمین ربات منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, adminprom_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "admindem" then
				function admindem_cb(arg, data)
					local nameid = index_function(tonumber(data.id))
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not is_admin1(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل ادمین ربات نبود*"..EndMsg, 0, "md")
					end
					table.remove(Config.admins, nameid)
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام ادمین ربات برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, admindem_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "visudo" then
				function visudo_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if already_sudo(tonumber(data.id)) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل سودو ربات بود*"..EndMsg, 0, "md")
					end
					table.insert(Config.sudo_users, tonumber(data.id))
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام سودو ربات منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, visudo_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
			if cmd == "desudo" then
				function desudo_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not already_sudo(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل سودو ربات نبود*"..EndMsg, 0, "md")
					end
					table.remove(Config.sudo_users, getindex( Config.sudo_users, tonumber(data.id)))
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام سودو ربات برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.sender_user_id
				}, desudo_cb, {chat_id=data.chat_id,user_id=data.sender_user_id})
			end
		end
	end
	function action_by_username(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		cmd = arg.cmd
		if not arg.username then return false end
		if data.id then
			if cmd == "warn" then
				function warn_cb(arg, data)
					if not data.id then return end
					msg = arg.msg
					hashwarn = arg.chat_id..':warn'
					warnhash = redis:hget(RedisIndex..hashwarn, data.id) or 1
					max_warn = tonumber(redis:get(RedisIndex..'max_warn:'..arg.chat_id) or 5)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم به خودم اخطار دهم*"..EndMsg, 0, "md")
					end
					if is_mod1(arg.chat_id, data.id) and not is_admin1(data.id)then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید به مدیران،صاحبان گروه، و ادمین های ربات اخطار دهید*"..EndMsg, 0, "md")
					end
					if is_admin1(data.id)then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید به ادمین های ربات اخطار دهید*"..EndMsg, 0, "md")
					end
					if tonumber(warnhash) == tonumber(max_warn) then
						kick_user(data.id, arg.chat_id)
						redis:hdel(RedisIndex..hashwarn, data.id, '0')
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." به دلیل دریافت اخطار بیش از حد اخراج شد\nتعداد اخطار ها : "..warnhash.."/"..max_warn..""..EndMsg, 0, "md")
					else
						redis:hset(RedisIndex..hashwarn, data.id, tonumber(warnhash) + 1)
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *شما یک اخطار دریافت کردید*\n*تعداد اخطار های شما : "..warnhash.."/"..max_warn.."*"..EndMsg, 0, "md")
					end
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, warn_cb, {chat_id=arg.chat_id,user_id=data.id,msg=arg.msg})
			end
			if cmd == "unwarn" then
				if not data.id then return end
				function unwarn_cb(arg, data)
					hashwarn = arg.chat_id..':warn'
					warnhash = redis:hget(RedisIndex..hashwarn, data.id) or 1
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not redis:hget(RedisIndex..hashwarn, data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *هیچ اخطاری دریافت نکرده*", 0, "md")
					else
						redis:hdel(RedisIndex..hashwarn, data.id, '0')
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*تمامی اخطار های* `"..data.id.."` - "..user_name.." *پاک شدند*"..EndMsg, 0, "md")
					end
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, unwarn_cb, {chat_id=arg.chat_id,user_id=data.id,msg=arg.msg})
			end
			if cmd == "setwhitelist" then
				function setwhitelist_cb(arg, data)
					if not data.id then return end
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل در لیست ویژه بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به لیست ویژه اضافه شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, setwhitelist_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "remwhitelist" then
				function remwhitelist_cb(arg, data)
					if not data.id then return end
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل در لیست ویژه نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از لیست ویژه حذف شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, remwhitelist_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "setowner" then
				function owner_cb(arg, data)
					if not data.id then return end
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Owners:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مالک گروه بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Owners:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام مالک گروه منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, owner_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "promote" then
				function promote_cb(arg, data)
					if not data.id then return end
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Mods:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مدیر گروه بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Mods:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام مدیر گروه منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, promote_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "remowner" then
				function rem_owner_cb(arg, data)
					if not data.id then return end
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Owners:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مالک گروه نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Owners:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام مالک گروه برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, rem_owner_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "demote" then
				function demote_cb(arg, data)
					if not data.id then return end
					if data.username and data.username ~= "" then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Mods:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مدیر گروه نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Mods:"..arg.chat_id,data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام مدیر گروه برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, demote_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "res" then
				function res_cb(arg, data)
					if not data.id then return end
					if data.last_name then
						user_name = check_markdown(data.first_name).." "..check_markdown(data.last_name)
					else
						user_name = check_markdown(data.first_name)
					end
					text = Source_Start.."`اطلاعات برای :` @"..check_markdown(data.username).."\n"..Source_Start.."`نام :` "..user_name.."\n"..Source_Start.."`ایدی :` *"..data.id.."*"
					return tdbot.sendMessage(arg.chat_id, "", 0, text, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, res_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "ban" then
				function ban_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از گروه محروم کنم*"..EndMsg, 0, "md")
					end
					if is_mod1(arg.chat_id, data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید مدیران،صاحبان گروه، و ادمین های ربات رو از گروه محروم کنید*"..EndMsg, 0, "md")
					end
					local list = redis:sismember(RedisIndex.."Banned:"..arg.chat_id,data.id)
					if list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه محروم بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."Banned:"..arg.chat_id,data.id)
					kick_user(data.id, arg.chat_id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه محروم شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, ban_cb, {chat_id=arg.chat_id,user_id=data.id}))
			end
			if cmd == "unban" then
				function unban_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local list = redis:sismember(RedisIndex.."Banned:"..arg.chat_id,data.id)
					if not list then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه محروم نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."Banned:"..arg.chat_id,data.id)
					channel_unblock(arg.chat_id, data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از محرومیت گروه خارج شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, unban_cb, {chat_id=arg.chat_id,user_id=data.id}))
			end
			if cmd == "silent" then
				function silent_cb(arg, data)
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم توانایی چت کردن رو از خودم بگیرم*"..EndMsg, 0, "md")
					end
					if is_mod1(arg.chat_id, data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه، و ادمین های ربات بگیرید*"..EndMsg, 0, "md")
					end
					local function check_silent(msg, is_silent)
						local user_name = msg.user_name
						arg = msg.arg
						if is_silent then
							return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل توانایی چت کردن رو نداشت*"..EndMsg, 0, "md")
						end
						silent_user(arg.chat_id, data.id)
						redis:sadd(RedisIndex.."Silentlist:"..arg.chat_id,data.id)
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *توانایی چت کردن رو از دست داد*"..EndMsg, 0, "md")
					end
					is_silent_user(data.id, arg.chat_id, {arg=arg, user_name=user_name,id=data.id}, check_silent)
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, silent_cb, {chat_id=arg.chat_id,user_id=data.id}))
			end
			if cmd == "unsilent" then
				function unsilent_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					local function check_silent(msg, is_silent)
						local user_name = msg.user_name
						arg = msg.arg
						if not is_silent then
							return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل توانایی چت کردن را داشت*"..EndMsg, 0, "md")
						end
						unsilent_user(arg.chat_id, data.id)
						redis:srem(RedisIndex.."Silentlist:"..arg.chat_id,data.id)
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *توانایی چت کردن رو به دست آورد*"..EndMsg, 0, "md")
					end
					is_silent_user(data.id, arg.chat_id, {arg=arg, user_name=user_name,id=data.id}, check_silent)
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, unsilent_cb, {chat_id=arg.chat_id,user_id=data.id}))
			end
			if cmd == "banall" then
				function gban_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if data.id == our_id then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از تمام گروه های ربات محروم کنم*"..EndMsg, 0, "md")
					end
					if is_admin1(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید ادمین های ربات رو از تمامی گروه های ربات محروم کنید*"..EndMsg, 0, "md")
					end
					if is_gbanned(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه های ربات محروم بود*"..EndMsg, 0, "md")
					end
					redis:sadd(RedisIndex.."GBanned",data.id)
					kick_user(data.id, arg.chat_id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از تمام گروه های ربات محروم شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, gban_cb, {chat_id=arg.chat_id,user_id=data.id}))
			end
			if cmd == "unbanall" then
				function ungban_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not is_gbanned(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از گروه های ربات محروم نبود*"..EndMsg, 0, "md")
					end
					redis:srem(RedisIndex.."GBanned",data.id)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از محرومیت گروه های ربات خارج شد*"..EndMsg, 0, "md")
				end
				assert(tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, ungban_cb, {chat_id=arg.chat_id,user_id=data.id}))
			end
			if cmd == "kick" then
				if not data.id then return end
				if data.id == our_id then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از گروه اخراج کنم کنم*"..EndMsg, 0, "md")
				elseif is_mod1(arg.chat_id, data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو اخراج کنید*"..EndMsg, 0, "md")
				else
					kick_user(data.id, arg.chat_id)
					sleep(1)
					channel_unblock(arg.chat_id, data.id)
				end
			end
			if cmd == "delall" then
				if not data.id then return end
				if is_mod1(arg.chat_id, data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید پیام های مدیران،صاحبان گروه و ادمین های ربات رو پاک کنید*"..EndMsg, 0, "md")
				else
					tdbot.deleteMessagesFromUser(arg.chat_id, data.id, dl_cb, nil)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*تمام پیام های* "..data.title.." *[ "..data.id.." ]* *پاک شد*"..EndMsg, 0, "md")
				end
			end
			if cmd == "adminprom" then
				function adminprom_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if is_admin1(tonumber(data.id)) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل ادمین ربات بود*"..EndMsg, 0, "md")
					end
					table.insert(Config.admins, {tonumber(data.id), user_name})
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام ادمین ربات منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, adminprom_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "admindem" then
				function admindem_cb(arg, data)
					if not data.id then return end
					local nameid = index_function(tonumber(data.id))
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not is_admin1(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل ادمین ربات نبود*"..EndMsg, 0, "md")
					end
					table.remove(Config.admins, nameid)
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام ادمین ربات برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, admindem_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "visudo" then
				function visudo_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if already_sudo(tonumber(data.id)) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل سودو ربات بود*"..EndMsg, 0, "md")
					end
					table.insert(Config.sudo_users, tonumber(data.id))
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام سودو ربات منتصب شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, visudo_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
			if cmd == "desudo" then
				function desudo_cb(arg, data)
					if not data.id then return end
					if data.username then
						user_name = '@'..check_markdown(data.username)
					else
						user_name = check_markdown(data.first_name)
					end
					if not already_sudo(data.id) then
						return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل سودو ربات نبود*"..EndMsg, 0, "md")
					end
					table.remove(Config.sudo_users, getindex( Config.sudo_users, tonumber(data.id)))
					save_config()
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام سودو ربات برکنار شد*"..EndMsg, 0, "md")
				end
				tdbot_function ({
				_ = "getUser",
				user_id = data.id
				}, desudo_cb, {chat_id=arg.chat_id,user_id=data.id})
			end
		end
	end
	function action_by_id(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		cmd = arg.cmd
		if not tonumber(arg.user_id) then return false end
		if data.id then
			if data.username then
				user_name = '@'..check_markdown(data.username)
			else
				user_name = check_markdown(data.first_name)
			end
			if cmd == "warn" then
				if data.id == our_id then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم به خودم اخطار دهم*"..EndMsg, 0, "md")
				end
				if is_mod1(arg.chat_id, data.id) and not is_admin1(msg.from.id)then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید به مدیران،صاحبان گروه، و ادمین های ربات اخطار دهید*"..EndMsg, 0, "md")
				end
				if is_admin1(data.id)then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید به ادمین های ربات اخطار دهید*"..EndMsg, 0, "md")
				end
				if tonumber(warnhash) == tonumber(max_warn) then
					kick_user(data.id, arg.chat_id)
					redis:hdel(RedisIndex..hashwarn, data.id, '0')
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." به دلیل دریافت اخطار بیش از حد اخراج شد\nتعداد اخطار ها : "..hashwarn.."/"..max_warn..""..EndMsg, 0, "md")
				else
					redis:hset(RedisIndex..hashwarn, data.id, tonumber(warnhash) + 1)
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *شما یک اخطار دریافت کردید*\n*تعداد اخطار های شما : "..warnhash.."/"..max_warn.."*"..EndMsg, 0, "md")
				end
			end
			if cmd == "unwarn" then
				if not redis:hget(RedisIndex..hashwarn, data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *هیچ اخطاری دریافت نکرده*"..EndMsg, 0, "md")
				else
					redis:hdel(RedisIndex..hashwarn, data.id, '0')
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*تمامی اخطار های* `"..data.id.."` - "..user_name.." *پاک شدند*"..EndMsg, 0, "md")
				end
			end
			if cmd == "setwhitelist" then
				local list = redis:sismember(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
				if list then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل در لیست ویژه بود*"..EndMsg, 0, "md")
				end
				redis:sadd(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به لیست ویژه اضافه شد*"..EndMsg, 0, "md")
			end
			if cmd == "remwhitelist" then
				local list = redis:sismember(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
				if not list then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل در لیست ویژه نبود*"..EndMsg, 0, "md")
				end
				redis:srem(RedisIndex.."Whitelist:"..arg.chat_id,data.id)
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از لیست ویژه حذف شد*"..EndMsg, 0, "md")
			end
			if cmd == "setowner" then
				local list = redis:sismember(RedisIndex.."Owners:"..arg.chat_id,data.id)
				if list then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مالک گروه بود*"..EndMsg, 0, "md")
				end
				redis:sadd(RedisIndex.."Owners:"..arg.chat_id,data.id)
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام مالک گروه منتصب شد*"..EndMsg, 0, "md")
			end
			if cmd == "promote" then
				local list = redis:sismember(RedisIndex.."Mods:"..arg.chat_id,data.id)
				if list then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مدیر گروه بود*"..EndMsg, 0, "md")
				end
				redis:sadd(RedisIndex.."Mods:"..arg.chat_id,data.id)
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام مدیر گروه منتصب شد*"..EndMsg, 0, "md")
			end
			if cmd == "remowner" then
				local list = redis:sismember(RedisIndex.."Owners:"..arg.chat_id,data.id)
				if not list then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.."*از قبل مالک گروه نبود*"..EndMsg, 0, "md")
				end
				redis:srem(RedisIndex.."Owners:"..arg.chat_id,data.id)
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام مالک گروه برکنار شد*"..EndMsg, 0, "md")
			end
			if cmd == "demote" then
				local list = redis:sismember(RedisIndex.."Mods:"..arg.chat_id,data.id)
				if not list then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل مدیر گروه نبود*"..EndMsg, 0, "md")
				end
				redis:srem(RedisIndex.."Mods:"..arg.chat_id,data.id)
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام مدیر گروه برکنار شد*"..EndMsg, 0, "md")
			end
			if cmd == "kick" then
				if tonumber(data.id) == our_id then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از گروه اخراج کنم*"..EndMsg, 0, "md")
				elseif is_mod1(arg.chat_id, userid) then
					tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو اخراج کنید*"..EndMsg, 0, "md")
				else
					kick_user(data.id, arg.chat_id)
					sleep(1)
					channel_unblock(arg.chat_id, data.id)
				end
			end
			if cmd == "delall" then
				if is_mod1(arg.chat_id, data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید پیام های مدیران،صاحبان گروه و ادمین های ربات رو پاک کنید*"..EndMsg, 0, "md")
				else
					tdbot.deleteMessagesFromUser(arg.chat_id, data.id, dl_cb, nil)
					tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'تمامی پیام های '..data.id..' پاک شد'..EndMsg,17,string.len(data.id))
				end
			end
			if cmd == "banall" then
				if tonumber(data.id) == our_id then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*من نمیتوانم خودم رو از تمام گروه های ربات محروم کنم*"..EndMsg, 0, "md")
				end
				if is_admin1(data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید ادمین های ربات رو از گروه های ربات محروم کنید*"..EndMsg, 0, "md")
				end
				if is_gbanned(data.id) then
					tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر '..data.id..' از گروه های ربات محروم بود'..EndMsg,8,string.len(data.id))
				end
				redis:sadd(RedisIndex.."GBanned",data.id)
				kick_user(data.id, arg.chat_id)
				tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر '..data.id..' از تمام گروه هار ربات محروم شد'..EndMsg,8,string.len(data.id))
			end
			if cmd == "unbanall" then
				if not is_gbanned(data.id) then
					tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر '..data.id..' از گروه های ربات محروم نبود'..EndMsg,8,string.len(data.id))
				end
				redis:srem(RedisIndex.."GBanned",data.id)
				tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر '..data.id..' از محرومیت گروه های ربات خارج شد'..EndMsg,8,string.len(data.id))
			end
			if cmd == "ban" then
				if tonumber(data.id) == our_id then
					return tdbot.sendMessage(arg.chat_id, arg.id, 0, Source_Start.."*من نمیتوانم خودم رو از گروه محروم کنم*"..EndMsg, 0, "md")
				end
				if is_mod1(arg.chat_id, tonumber(data.id)) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید مدیران،صاحبان گروه و ادمین های ربات رو از گروه محروم کنید*"..EndMsg, 0, "md")
				end
				if is_banned(data.id, arg.chat_id) then
					tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر '..data.id..' از گروه محروم بود'..EndMsg,8,string.len(data.id))
				end
				redis:sadd(RedisIndex.."Banned:"..arg.chat_id,data.id)
				kick_user(data.id, arg.chat_id)
				tdbot.sendMention(arg.chat_id,data.id, arg.id,'کاربر '..data.id..' از گروه محروم شد'..EndMsg,8,string.len(data.id))
			end
			if cmd == "unban" then
				if not is_banned(data.id, arg.chat_id) then
					tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر '..data.id..' از گروه محروم نبود'..EndMsg,8,string.len(data.id))
				end
				redis:srem(RedisIndex.."Banned:"..arg.chat_id,data.id)
				channel_unblock(arg.chat_id, data.id)
				tdbot.sendMention(arg.chat_id,data.id, arg.id,Source_Start..'کاربر  '..data.id..' از محرومیت گروه خارج شد'..EndMsg,8,string.len(data.id))
			end
			if cmd == "silent" then
				if tonumber(data.id) == our_id then
					return tdbot.sendMessage(arg.chat_id, arg.id, 0, Source_Start.."*من نمیتوانم توانایی چت کردن رو از خودم بگیرم*"..EndMsg, 0, "md")
				end
				if is_mod1(arg.chat_id, tonumber(data.id)) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه و ادمین های ربات بگیرید*"..EndMsg, 0, "md")
				end
				local function check_silentt(roo, is_silent)
					if is_silent then
						tdbot.sendMention(arg.chat_id,roo.id, arg.id,Source_Start..'کاربر '..roo.id..' از قبل توانایی چت کردن رو نداشت'..EndMsg,8,string.len(roo.id))
					end
					silent_user(arg.chat_id, roo.id)
					redis:sadd(RedisIndex.."Silentlist:"..arg.chat_id,roo.id)
					tdbot.sendMention(arg.chat_id,roo.id, arg.id,Source_Start..'کاربر '..roo.id..' توانایی چت کردن رو از دست داد'..EndMsg,8,string.len(roo.id))
				end
				is_silent_user(data.id, arg.chat_id, {id=data.id}, check_silentt)
			end
			if cmd == "unsilent" then
				local function check_silent(roo, is_silent)
					if not is_silent then
						return tdbot.sendMention(arg.chat_id,roo.id, arg.id,Source_Start..'کاربر '..roo.id..' از قبل توانایی چت کردن رو داشت'..EndMsg,8,string.len(roo.id))
					end
					unsilent_user(arg.chat_id, roo.id)
					redis:srem(RedisIndex.."Silentlist:"..arg.chat_id,roo.id)
					return tdbot.sendMention(arg.chat_id,roo.id, arg.id,Source_Start..'کاربر '..roo.id..' توانایی چت کردن رو به دست آورد'..EndMsg,8,string.len(roo.id))
				end
				is_silent_user(tonumber(data.id), arg.chat_id, {id=data.id}, check_silent)
			end
			if cmd == "whois" then
				if data.username then
					username = '@'..check_markdown(data.username)
				else
					username = 'ندارد'
				end
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start..'اطلاعات برای [ '..data.id..' ] :\n'..Source_Start..'یوزرنیم : '..username..'\n'..Source_Start..'نام : '..check_markdown(data.first_name), 0, "md")
			end
			if cmd == "adminprom" then
				if is_admin1(tonumber(data.id)) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل ادمین ربات بود*"..EndMsg, 0, "md")
				end
				table.insert(Config.admins, {tonumber(data.id), user_name})
				save_config()
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام ادمین ربات منتصب شد*"..EndMsg, 0, "md")
			end
			if cmd == "admindem" then
				local nameid = index_function(tonumber(data.id))
				if not is_admin1(data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل ادمین ربات نبود*"..EndMsg, 0, "md")
				end
				table.remove(Config.admins, nameid)
				save_config()
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام ادمین ربات برکنار شد*"..EndMsg, 0, "md")
			end
			if cmd == "visudo" then
				if already_sudo(tonumber(data.id)) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل سودو ربات بود*"..EndMsg, 0, "md")
				end
				table.insert(Config.sudo_users, tonumber(data.id))
				save_config()
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *به مقام سودو ربات منتصب شد*"..EndMsg, 0, "md")
			end
			if cmd == "desudo" then
				if not already_sudo(data.id) then
					return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از قبل سودو ربات نبود*"..EndMsg, 0, "md")
				end
				table.remove(Config.sudo_users, getindex( Config.sudo_users, tonumber(data.id)))
				save_config()
				return tdbot.sendMessage(arg.chat_id, "", 0, Source_Start.."*کاربر* `"..data.id.."` - "..user_name.." *از مقام سودو ربات برکنار شد*"..EndMsg, 0, "md")
			end
		end
	end
	local api_key = nil
	local base_api = "https://maps.googleapis.com/maps/api"
	function get_latlong(area)
		local api      = base_api .. "/geocode/json?"
		local parameters = "address=".. (URL.escape(area) or "")
		if api_key ~= nil then
			parameters = parameters .. "&key="..api_key
		end
		local res, code = https.request(api..parameters)
		if code ~=200 then return nil  end
		local data = json:decode(res)
		if (data.status == "ZERO_RESULTS") then
			return nil
		end
		if (data.status == "OK") then
			lat  = data.results[1].geometry.location.lat
			lng  = data.results[1].geometry.location.lng
			acc  = data.results[1].geometry.location_type
			types= data.results[1].types
			return lat,lng,acc,types
		end
	end
	function opizoLink(Url)
		local Opizo = http.request('http://enigma-dev.ir/api/opizo/?url='..URL.escape(Url))
		if Opizo then
			if json:decode(Opizo) then
				OpizoJ = json:decode(Opizo)
				return OpizoJ.result or OpizoJ.description
			end
		end
	end
	function get_staticmap(area)
		local api        = base_api .. "/staticmap?"
		local lat,lng,acc,types = get_latlong(area)
		if not types[1] then return end
		local scale = types[1]
		if scale == "locality" then
			zoom=8
		elseif scale == "country" then
			zoom=4
		else
			zoom = 13
		end
		local parameters =
		"size=600x300" ..
		"&zoom="  .. zoom ..
		"&center=" .. URL.escape(area) ..
		"&markers=color:red"..URL.escape("|"..area)
		if api_key ~= nil and api_key ~= "" then
			parameters = parameters .. "&key="..api_key
		end
		return lat, lng, api..parameters
	end
	function get_weather(location)
		print("Finding weather in ", location)
		local BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
		local url = BASE_URL
		url = url..'?q='..location..'&APPID=eedbc05ba060c787ab0614cad1f2e12b'
		url = url..'&units=metric'
		local b, c, h = http.request(url)
		if c ~= 200 then return nil end
		local weather = json:decode(b)
		local city = weather.name
		local country = weather.sys.country
		local temp = 'دمای شهر '..city..' هم اکنون '..weather.main.temp..' درجه سانتی گراد می باشد\n____________________'
		local conditions = 'شرایط فعلی آب و هوا : '
		if weather.weather[1].main == 'Clear' then
			conditions = conditions .. 'آفتابی☀'
		elseif weather.weather[1].main == 'Clouds' then
			conditions = conditions .. 'ابری ☁☁'
		elseif weather.weather[1].main == 'Rain' then
			conditions = conditions .. 'بارانی ☔'
		elseif weather.weather[1].main == 'Thunderstorm' then
			conditions = conditions .. 'طوفانی ☔☔☔☔'
		elseif weather.weather[1].main == 'Mist' then
			conditions = conditions .. 'مه 💨'
		end
		tdbot.sendMessage(msg.chat_id , msg.id, 1, temp .. '\n' .. conditions, 0, 'md')
	end
	function calc(exp)
		url = 'http://api.mathjs.org/v1/'
		url = url..'?expr='..URL.escape(exp)
		b,c = http.request(url)
		text = nil
		if c == 200 then
			text = 'Result = '..b..'\n____________________'..channel_username
		elseif c == 400 then
			text = b
		else
			text = 'Unexpected error\n'
			..'Is api.mathjs.org up?'
		end
		return text
	end
	function exi_filef(path, suffix)
		local files = {}
		local pth = tostring(path)
		local psv = tostring(suffix)
		for k, v in pairs(scandir(pth)) do
			if (v:match('.'..psv..'$')) then
				table.insert(files, v)
			end
		end
		return files
	end
	function file_exif(name, path, suffix)
		local fname = tostring(name)
		local pth = tostring(path)
		local psv = tostring(suffix)
		for k,v in pairs(exi_filef(pth, psv)) do
			if fname == v then
				return true
			end
		end
		return false
	end
	function getRandomButts(attempt)
		attempt = attempt or 0
		attempt = attempt + 1
		local res,status = http.request("http://api.obutts.ru/noise/1")
		if status ~= 200 then return nil end
		local data = json:decode(res)[1]
		if not data and attempt <= 3 then
			return getRandomButts(attempt)
		end
		return 'http://media.obutts.ru/' .. data.preview
	end
	function getRandomBoobs(attempt)
		attempt = attempt or 0
		attempt = attempt + 1
		local res,status = http.request("http://api.oboobs.ru/noise/1")
		if status ~= 200 then return nil end
		local data = json:decode(res)[1]
		if not data and attempt < 10 then
			return getRandomBoobs(attempt)
		end
		return 'http://media.oboobs.ru/' .. data.preview
	end
	function modadd(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
			tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start..'`ربات در` #لیست `گروه ربات از قبل بود`'..EndMsg, 0, 'md')
		else
		redis:set(RedisIndex..'ExpireDate:'..msg.to.id,true)
		redis:setex(RedisIndex..'ExpireDate:'..msg.to.id, 172800, true)
		set_configadd(msg)
		if not redis:get(RedisIndex..'CheckExpire::'..msg.to.id) then
		redis:set(RedisIndex..'CheckExpire::'..msg.to.id,true)
		end
		redis:sadd(RedisIndex.."Group" ,msg.to.id)
		redis:set(RedisIndex.."Gpnameset"..msg.to.id ,msg.to.title)
		redis:set(RedisIndex.."CheckBot:"..msg.to.id ,true)
		tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start..'*گروه* '..check_markdown(msg.to.title)..' *به مدت [2] روز شارژ برای تست کامل توسط* `'..msg.from.id..'` - @'..check_markdown(msg.from.username)..' *به لیست گروه های ربات اضافه شد*'..EndMsg, 0, 'md')
		end
	end
	function modrem(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if not is_admin(msg) then
			tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start..'`شما مدیر` #ربات `نمیباشید`'..EndMsg, 0, 'md')
		end
		if not redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
			tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start..'`گروه در` #لیست `گروه ربات  نیست`'..EndMsg, 0, 'md')
		end
		redis:srem(RedisIndex.."Group" ,msg.to.id)
		redis:del(RedisIndex.."Gpnameset"..msg.to.id)
		redis:del(RedisIndex.."CheckBot:"..msg.to.id)
		redis:del(RedisIndex.."Whitelist:"..msg.to.id)
		redis:del(RedisIndex.."Banned:"..msg.to.id)
		redis:del(RedisIndex.."Owners:"..msg.to.id)
		redis:del(RedisIndex.."Mods:"..msg.to.id)
		redis:del(RedisIndex..'filterlist:'..msg.to.id)
		redis:del(RedisIndex..msg.to.id..'rules')
		redis:del(RedisIndex..'setwelcome:'..msg.chat_id)
		redis:del(RedisIndex..'lock_link:'..msg.chat_id)
		redis:del(RedisIndex..'lock_join:'..msg.chat_id)
		redis:del(RedisIndex..'lock_tag:'..msg.chat_id)
		redis:del(RedisIndex..'lock_username:'..msg.chat_id)
		redis:del(RedisIndex..'lock_pin:'..msg.chat_id)
		redis:del(RedisIndex..'lock_arabic:'..msg.chat_id)
		redis:del(RedisIndex..'lock_mention:'..msg.chat_id)
		redis:del(RedisIndex..'lock_edit:'..msg.chat_id)
		redis:del(RedisIndex..'lock_spam:'..msg.chat_id)
		redis:del(RedisIndex..'lock_flood:'..msg.chat_id)
		redis:del(RedisIndex..'lock_markdown:'..msg.chat_id)
		redis:del(RedisIndex..'lock_webpage:'..msg.chat_id)
		redis:del(RedisIndex..'welcome:'..msg.chat_id)
		redis:del(RedisIndex..'views:'..msg.chat_id)
		redis:del(RedisIndex..'lock_bots:'..msg.chat_id)
		redis:del(RedisIndex..'mute_all:'..msg.chat_id)
		redis:del(RedisIndex..'mute_gif:'..msg.chat_id)
		redis:del(RedisIndex..'mute_photo:'..msg.chat_id)
		redis:del(RedisIndex..'mute_sticker:'..msg.chat_id)
		redis:del(RedisIndex..'mute_contact:'..msg.chat_id)
		redis:del(RedisIndex..'mute_inline:'..msg.chat_id)
		redis:del(RedisIndex..'mute_game:'..msg.chat_id)
		redis:del(RedisIndex..'mute_text:'..msg.chat_id)
		redis:del(RedisIndex..'mute_keyboard:'..msg.chat_id)
		redis:del(RedisIndex..'mute_forward:'..msg.chat_id)
		redis:del(RedisIndex..'mute_location:'..msg.chat_id)
		redis:del(RedisIndex..'mute_document:'..msg.chat_id)
		redis:del(RedisIndex..'mute_voice:'..msg.chat_id)
		redis:del(RedisIndex..'mute_audio:'..msg.chat_id)
		redis:del(RedisIndex..'mute_video:'..msg.chat_id)
		redis:del(RedisIndex..'mute_video_note:'..msg.chat_id)
		redis:del(RedisIndex..'mute_tgservice:'..msg.chat_id)
		redis:del(RedisIndex..msg.to.id..'set_char')
		redis:del(RedisIndex..msg.to.id..'num_msg_max')
		redis:del(RedisIndex..msg.to.id..'time_check')
		tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start..'*گروه* '..check_markdown(msg.to.title)..' *توسط* `'..msg.from.id..'` - @'..check_markdown(msg.from.username)..' *از لیست گروه های ربات حذف شد*'..EndMsg, 0, 'md')
	end
	function filter_word(msg, word)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:hget(RedisIndex..'filterlist:'..msg.to.id, word) then
			tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start.."`کلمه` *"..word.."* `از قبل فیلتر بود`"..EndMsg, 0, 'md')
		end
		redis:hset(RedisIndex..'filterlist:'..msg.to.id, word, "newword")
		tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start.."`کلمه` *[ "..word.." ]* `توسط` *"..msg.from.id.."* - @"..check_markdown(msg.from.username).." `به لیست کلمات فیلتر شده اضافه شد`"..EndMsg, 0, 'md')
	end
	function unfilter_word(msg, word)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if not redis:hget(RedisIndex..'filterlist:'..msg.to.id, word) then
			tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start.."`کلمه` *"..word.."* `از قبل فیلتر نبود`"..EndMsg, 0, 'md')
		else
			redis:hdel(RedisIndex..'filterlist:'..msg.to.id, word)
			tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start.."`کلمه` *[ "..word.." ]* `توسط` *"..msg.from.id.."* - @"..check_markdown(msg.from.username).." `از لیست کلمات فیلتر شده حذف شد`"..EndMsg, 0, 'md')
		end
	end
	function filter_list(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		local names = redis:hkeys(RedisIndex..'filterlist:'..msg.to.id)
		filterlist = Source_Start..'`لیست کلمات فیلتر شده :`\n'
		local b = 1
		for i = 1, #names do
			filterlist = filterlist .. b .. ". " .. names[i] .. "\n"
			b = b + 1
		end
		if #names == 0 then
			filterlist = Source_Start.."`لیست کلمات فیلتر شده خالی است`"..EndMsg
		end
		tdbot.sendMessage(msg.chat_id, msg.id, 1, filterlist, 1, 'md')
	end
	function group_settings(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
			if redis:get(RedisIndex..msg.chat_id..'num_msg_max') then
				NUM_MSG_MAX = redis:get(RedisIndex..msg.chat_id..'num_msg_max')
			else
				NUM_MSG_MAX = 5
			end
			if redis:get(RedisIndex..msg.chat_id..'set_char') then
				SETCHAR = redis:get(RedisIndex..msg.chat_id..'set_char')
			else
				SETCHAR = 400
			end
			if redis:get(RedisIndex..msg.chat_id..'time_check') then
				TIME_CHECK = redis:get(RedisIndex..msg.chat_id..'time_check')
			else
				TIME_CHECK = 2
			end
		end
		lock_link = redis:get(RedisIndex..'lock_link:'..msg.chat_id)
		lock_join = redis:get(RedisIndex..'lock_join:'..msg.chat_id)
		lock_tag = redis:get(RedisIndex..'lock_tag:'..msg.chat_id)
		lock_username = redis:get(RedisIndex..'lock_username:'..msg.chat_id)
		lock_pin = redis:get(RedisIndex..'lock_pin:'..msg.chat_id)
		lock_arabic = redis:get(RedisIndex..'lock_arabic:'..msg.chat_id)
		lock_english = redis:get(RedisIndex..'lock_english:'..msg.chat_id)
		lock_mention = redis:get(RedisIndex..'lock_mention:'..msg.chat_id)
		lock_edit = redis:get(RedisIndex..'lock_edit:'..msg.chat_id)
		lock_spam = redis:get(RedisIndex..'lock_spam:'..msg.chat_id)
		lock_flood = redis:get(RedisIndex..'lock_flood:'..msg.chat_id)
		lock_markdown = redis:get(RedisIndex..'lock_markdown:'..msg.chat_id)
		lock_webpage = redis:get(RedisIndex..'lock_webpage:'..msg.chat_id)
		lock_welcome = redis:get(RedisIndex..'welcome:'..msg.chat_id)
		lock_views = redis:get(RedisIndex..'lock_views:'..msg.chat_id)
		lock_bots = redis:get(RedisIndex..'lock_bots:'..msg.chat_id)
		lock_tabchi = redis:get(RedisIndex..'lock_tabchi:'..msg.chat_id)
		mute_all = redis:get(RedisIndex..'mute_all:'..msg.chat_id)
		mute_gif = redis:get(RedisIndex..'mute_gif:'..msg.chat_id)
		mute_photo = redis:get(RedisIndex..'mute_photo:'..msg.chat_id)
		mute_sticker = redis:get(RedisIndex..'mute_sticker:'..msg.chat_id)
		mute_contact = redis:get(RedisIndex..'mute_contact:'..msg.chat_id)
		mute_inline = redis:get(RedisIndex..'mute_inline:'..msg.chat_id)
		mute_game = redis:get(RedisIndex..'mute_game:'..msg.chat_id)
		mute_text = redis:get(RedisIndex..'mute_text:'..msg.chat_id)
		mute_keyboard = redis:get(RedisIndex..'mute_keyboard:'..msg.chat_id)
		mute_forward = redis:get(RedisIndex..'mute_forward:'..msg.chat_id)
		mute_forwarduser = redis:get(RedisIndex..'mute_forwarduser:'..msg.chat_id)
		mute_location = redis:get(RedisIndex..'mute_location:'..msg.chat_id)
		mute_document = redis:get(RedisIndex..'mute_document:'..msg.chat_id)
		mute_voice = redis:get(RedisIndex..'mute_voice:'..msg.chat_id)
		mute_audio = redis:get(RedisIndex..'mute_audio:'..msg.chat_id)
		mute_video = redis:get(RedisIndex..'mute_video:'..msg.chat_id)
		mute_video_note = redis:get(RedisIndex..'mute_video_note:'..msg.chat_id)
		mute_tgservice = redis:get(RedisIndex..'mute_tgservice:'..msg.chat_id)
		L_floodmod = redis:get(RedisIndex..msg.to.id..'floodmod')
		local gif = (mute_gif == "Warn") and "اخطار" or ((mute_gif == "Kick") and "اخراج" or ((mute_gif == "Mute") and "سکوت" or ((mute_gif == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local photo = (mute_photo == "Warn") and "اخطار" or ((mute_photo == "Kick") and "اخراج" or ((mute_photo == "Mute") and "سکوت" or ((mute_photo == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local sticker = (mute_sticker == "Warn") and "اخطار" or ((mute_sticker == "Kick") and "اخراج" or ((mute_sticker == "Mute") and "سکوت" or ((mute_sticker == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local contact = (mute_contact == "Warn") and "اخطار" or ((mute_contact == "Kick") and "اخراج" or ((mute_contact == "Mute") and "سکوت" or ((mute_contact == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local inline = (mute_inline == "Warn") and "اخطار" or ((mute_inline == "Kick") and "اخراج" or ((mute_inline == "Mute") and "سکوت" or ((mute_inline == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local game = (mute_game == "Warn") and "اخطار" or ((mute_game == "Kick") and "اخراج" or ((mute_game == "Mute") and "سکوت" or ((mute_game == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local textt = (mute_text == "Warn") and "اخطار" or ((mute_text == "Kick") and "اخراج" or ((mute_text == "Mute") and "سکوت" or ((mute_text == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local keyboard = (mute_keyboard == "Warn") and "اخطار" or ((mute_keyboard == "Kick") and "اخراج" or ((mute_keyboard == "Mute") and "سکوت" or ((mute_keyboard == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local forward = (mute_forward == "Warn") and "اخطار" or ((mute_forward == "Kick") and "اخراج" or ((mute_forward == "Mute") and "سکوت" or ((mute_forward == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local forwarduser = (mute_forwarduser == "Warn") and "اخطار" or ((mute_forwarduser == "Kick") and "اخراج" or ((mute_forwarduser == "Mute") and "سکوت" or ((mute_forwarduser == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local views = (lock_views == "Warn") and "اخطار" or ((lock_views == "Kick") and "اخراج" or ((lock_views == "Mute") and "سکوت" or ((lock_views == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local location = (mute_location == "Warn") and "اخطار" or ((mute_location == "Kick") and "اخراج" or ((mute_location == "Mute") and "سکوت" or ((mute_location == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local document = (mute_document == "Warn") and "اخطار" or ((mute_document == "Kick") and "اخراج" or ((mute_document == "Mute") and "سکوت" or ((mute_document == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local voice = (mute_voice == "Warn") and "اخطار" or ((mute_voice == "Kick") and "اخراج" or ((mute_voice == "Mute") and "سکوت" or ((mute_voice == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local audio = (mute_audio == "Warn") and "اخطار" or ((mute_audio == "Kick") and "اخراج" or ((mute_audio == "Mute") and "سکوت" or ((mute_audio == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local video = (mute_video == "Warn") and "اخطار" or ((mute_video == "Kick") and "اخراج" or ((mute_video == "Mute") and "سکوت" or ((mute_video == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local video_note = (mute_video_note == "Warn") and "اخطار" or ((mute_video_note == "Kick") and "اخراج" or ((mute_video_note == "Mute") and "سکوت" or ((mute_video_note == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local link = (lock_link == "Warn") and "اخطار" or ((lock_link == "Kick") and "اخراج" or ((lock_link == "Mute") and "سکوت" or ((lock_link == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local tag = (lock_tag == "Warn") and "اخطار" or ((lock_tag == "Kick") and "اخراج" or ((lock_tag == "Mute") and "سکوت" or ((lock_tag == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local username = (lock_username == "Warn") and "اخطار" or ((lock_username == "Kick") and "اخراج" or ((lock_username == "Mute") and "سکوت" or ((lock_username == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local arabic = (lock_arabic == "Warn") and "اخطار" or ((lock_arabic == "Kick") and "اخراج" or ((lock_arabic == "Mute") and "سکوت" or ((lock_arabic == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local english = (lock_english == "Warn") and "اخطار" or ((lock_english == "Kick") and "اخراج" or ((lock_english == "Mute") and "سکوت" or ((lock_english == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local mention = (lock_mention == "Warn") and "اخطار" or ((lock_mention == "Kick") and "اخراج" or ((lock_mention == "Mute") and "سکوت" or ((lock_mention == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local edit = (lock_edit == "Warn") and "اخطار" or ((lock_edit == "Kick") and "اخراج" or ((lock_edit == "Mute") and "سکوت" or ((lock_edit == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local markdown = (lock_markdown == "Warn") and "اخطار" or ((lock_markdown == "Kick") and "اخراج" or ((lock_markdown == "Mute") and "سکوت" or ((lock_markdown == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local webpage = (lock_webpage == "Warn") and "اخطار" or ((lock_webpage == "Kick") and "اخراج" or ((lock_webpage == "Mute") and "سکوت" or ((lock_webpage == "Enable") and "MaTaDoRLock" or "MaTaDoRUnlock")))
		local bots =  (lock_bots == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local all =  (mute_all == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local tgservice =  (mute_tgservice == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local join =  (lock_join == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local pin =  (lock_pin == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local spam =  (lock_spam == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local flood =  (lock_flood == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local welcome = (lock_welcome == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local tabchi = (lock_tabchi == "Enable" and "MaTaDoRLock" or "MaTaDoRUnlock")
		local getadd = redis:hget(RedisIndex..'addmemset', msg.to.id) or "0"
		local add = redis:hget(RedisIndex..'addmeminv' ,msg.chat_id)
		local sadd = (add == 'on') and "فعال" or "غیرفعال"
		local delbottime = redis:get(RedisIndex.."deltimebot"..msg.chat_id) or 60
		local delbot = redis:get(RedisIndex.."delbot"..msg.to.id) and "فعال" or "غیرفعال"
		local mutetime = redis:get(RedisIndex.."TimeMuteset"..msg.to.id) or "ثبت نشده"
		L_lockgptime = redis:get(RedisIndex..'Lock_Gp:'..msg.to.id)
		local lockgptime = (L_lockgptime and "فعال" or "غیرفعال")
		local expire_date = ''
		local expi = redis:ttl(RedisIndex..'ExpireDate:'..msg.to.id)
		local floodmod = (L_floodmod == "Mute" and "سکوت کاربر" or "اخراج کاربر")
		if expi == -1 then
			expire_date = 'نامحدود!'
		else
			local day = math.floor(expi / 86400) + 1
			expire_date = day..' روز'
		end
		local t1 = redis:get(RedisIndex.."atolct1"..msg.chat_id)
		local t2 = redis:get(RedisIndex.."atolct2"..msg.chat_id)
		if t1 and t2 then
			stats1 = ''..t1..' && '..t2..''
		else
			stats1 = '`تنظیم نشده`'
		end
		text = "⇋ تنظیمات گروه ~> •("..check_markdown(msg.to.title)..")• :\n\n⌯ تنظیمات قفل •(پیشرفته)• ❦\n\n↜ لینک : ❲^"..link.."^❳\n↜ هشتگ : ❲^"..tag.."^❳\n↜‌ نام کاربری : ❲^"..username.."^❳\n↜ بازدید : ❲^"..views.."^❳\n↜ منشن : ❲^"..mention.."^❳\n↜ انگلیسی : ❲^"..english.."^❳\n↜ فارسی : ❲^"..arabic.."^❳\n↜ وب سایت : ❲^"..webpage.."^❳\n↜ فونت : ❲^"..markdown.."^❳\n↜ ربات : ❲^"..bots.."^❳\n\n⌯ تنظیمات رسانه •(پیشرفته)• ❦\n\n↜ گیف : ❲^"..gif.."^❳\n↜ عکس : ❲^"..photo.."^❳\n↜ فیلم : ❲^"..video.."^❳\n↜ سلفی : ❲^"..video_note.."^❳\n↜ آهنگ : ❲^"..audio.."^❳\n↜ ویس : ❲^"..voice.."^❳\n↜ متن : ❲^"..textt.."^❳\n↜ بازی : ❲^"..game.."^❳\n↜ استیکر : ❲^"..sticker.."^❳\n↜ مخاطب : ❲^"..contact.."^❳\n↜ مکان : ❲^"..location.."^❳\n↜ فایل : ❲^"..document.."^❳\n↜ دکمه شیشه ای : ❲^"..inline.."^❳\n↜ کیبورد : ❲^"..keyboard.."^❳\n↜ فوروارد کانال : ❲^"..forward.."^❳\n↜ فوروارد شخص : ❲^"..forwarduser.."^❳\n\n⌯ تنظیمات انتی اسپم •(پیشرفته)• ❦\n\n↜ آنتی فلود : ❲^"..flood.."^❳\n↜ آنتی اسپم : ❲^"..spam.."^❳\n↜ حالت آنتی فلود : ❲^"..floodmod.."^❳\n↜ حداکثر آنتی اسپم : "..SETCHAR.."\n↜ حداکثر آنتی فلود :"..NUM_MSG_MAX.."\n↜ زمان برسی آنتی فلود : "..TIME_CHECK.."\n\n⌯ •(تنظیمات بیشتر گروه)• ❦\n\n↜ قفل گروه  :‌ ❲^"..all.."^❳\n↜ قفل گروه زمانی :‌‌ "..lockgptime.."\n↜ قفل خودکار :  "..stats1.."\n↜زمان سکوت : "..mutetime.."\n↜ سرویس تلگرام :‌‌ ❲^"..tgservice.."^❳\n↜ ورود : ❲^"..join.."^❳\n↜ سنجاق پیام : ❲^"..pin.."^❳\n↜ خوشآمدگویی : ❲^"..welcome.."^❳\n↜ پاکسازی خودکار : ❲^"..delbot.."^❳\n↜ زمان پاکسازی خودکار‌ : "..delbottime.."\n↜ شناسایی تبچی : ❲^"..tabchi.."^❳\n↜ اد اجباری : ❲^"..sadd.."^❳\n↜ حداکثر اد اجباری : "..getadd.."\n↜ تاریخ انقضا : "..expire_date..""
		text = string.gsub(text, 'MaTaDoRUnlock', "غیرفعال")
		text = string.gsub(text, 'MaTaDoRLock', "فعال")
		text = string.gsub(text, 'اخطار', "اخطار")
		text = string.gsub(text, 'اخراج', "اخراج")
		text = string.gsub(text, 'سکوت', "سکوت")
		tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
	end
	function rank_reply(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		cmd = arg.cmd
		if data.sender_user_id then
			if not tonumber(data.sender_user_id) then return false end
			if cmd == "setrank" then
				redis:set(RedisIndex.."laghab:"..data.sender_user_id,arg.rank)
				tdbot.sendMention(arg.chat_id,data.sender_user_id, data.id,Source_Start.."مقام کاربر [ "..data.sender_user_id.." ] تنظیم شد به : ( "..arg.rank.." )"..EndMsg,15,string.len(data.sender_user_id))
			end
			if cmd == "delrank" then
				redis:del(RedisIndex.."laghab:"..data.sender_user_id)
				tdbot.sendMention(arg.chat_id,data.sender_user_id, data.id,Source_Start.."مقام کاربر [ "..data.sender_user_id.." ] حذف شد"..EndMsg,15,string.len(data.sender_user_id))
			end
		end
	end
	function rank_username(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		cmd = arg.cmd
		if not data.id then return end
		if data.id then
			if cmd == "setrank" then
				redis:set(RedisIndex.."laghab:"..data.id,arg.rank)
				tdbot.sendMention(arg.chat_id,data.id, data.id,Source_Start.."مقام کاربر [ "..data.id.." ] تنظیم شد به : ( "..arg.rank.." )"..EndMsg,15,string.len(data.id))
			end
			if cmd == "delrank" then
				redis:del(RedisIndex.."laghab:"..data.id)
				tdbot.sendMention(arg.chat_id,data.id, data.id,Source_Start.."مقام کاربر [ "..data.id.." ] حذف شد"..EndMsg,15,string.len(data.id))
			end
		end
	end
	function rank_id(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		cmd = arg.cmd
		if not tonumber(arg.user_id) then return false end
		if data.id then
			if data.first_name then
				if cmd == "setrank" then
					redis:set(RedisIndex.."laghab:"..data.id,arg.rank)
					tdbot.sendMention(arg.chat_id,data.id, data.id,Source_Start.."مقام کاربر [ "..data.id.." ] تنظیم شد به : ( "..arg.rank.." )"..EndMsg,15,string.len(data.id))
				end
				if cmd == "delrank" then
					redis:del(RedisIndex.."laghab:"..data.id)
					tdbot.sendMention(arg.chat_id,data.id, data.id,Source_Start.."مقام کاربر [ "..data.id.." ] حذف شد"..EndMsg,15,string.len(data.id))
				end
			end
		end
	end
	function info_by_reply(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if tonumber(data.sender_user_id) then
			function info_cb(arg, data)
				if data.username then
					username = "@"..check_markdown(data.username)
				else
					username = ""
				end
				if data.first_name then
					firstname = check_markdown(data.first_name)
				else
					firstname = ""
				end
				if data.last_name then
					lastname = check_markdown(data.last_name)
				else
					lastname = ""
				end
				local text = ""..Source_Start.."*نام :* `"..firstname.."`\n"..Source_Start.."*فامیلی :* `"..lastname.."`\n"..Source_Start.."*نام کاربری :* "..username.."\n"..Source_Start.."*آیدی :* `"..data.id.."`\n"
				if is_leader1(data.id) then
					text = text..Source_Start..'*مقام :* `سازنده سورس`\n'
				elseif is_sudo1(data.id) then
					text = text..Source_Start..'*مقام :* `سودو ربات`\n'
				elseif is_admin1(data.id) then
					text = text..Source_Start..'*مقام :* `ادمین ربات`\n'
				elseif is_owner1(arg.chat_id, data.id) then
					text = text..Source_Start..'*مقام :* `سازنده گروه`\n'
				elseif is_mod1(arg.chat_id, data.id) then
					text = text..Source_Start..'*مقام :* `مدیر گروه`\n'
				else
					text = text..Source_Start..'*مقام :* `کاربر عادی`\n'
				end
				local user_info = {}
				local uhash = 'user:'..data.id
				local user = redis:hgetall(RedisIndex..uhash)
				local um_hash = 'msgs:'..data.id..':'..arg.chat_id
				local gaps = 'msgs:'..arg.chat_id
				local hashss = 'laghab:'..tostring(data.id)
				laghab = redis:get(RedisIndex..hashss) or 'ثبت نشده'
				user_info_msgs = tonumber(redis:get(RedisIndex..um_hash) or 0)
				gap_info_msgs = tonumber(redis:get(RedisIndex..gaps) or 0)
				Percent_= tonumber(user_info_msgs) / tonumber(gap_info_msgs) * 100
				if Percent_ < 10 then
					Percent = '0'..string.sub(Percent_, 1, 4)
				elseif Percent_ >= 10 then
					Percent = string.sub(Percent_, 1, 5)
				end
				if tonumber(Percent) <= 10 then
					UsStatus = "ضعیف 😴"
				elseif tonumber(Percent) <= 20 then
					UsStatus = "معمولی 😊"
				elseif tonumber(Percent) <= 100 then
					UsStatus = "فعال 😎"
				end
				text = text..Source_Start..'*پیام های گروه :* `'..gap_info_msgs..'`\n'
				text = text..Source_Start..'*پیام های کاربر :* `'..user_info_msgs..'`\n'
				text = text..Source_Start..'*درصد پیام کاربر :* `('..Percent..'%)`\n'
				text = text..Source_Start..'*وضعیت کاربر :* `'..UsStatus..'`\n'
				text = text..Source_Start..'*لقب کاربر :* `'..laghab..'`'
				tdbot.sendMessage(arg.chat_id, arg.msgid, 0, text, 0, "md")
			end
			assert (tdbot_function ({
			_ = "getUser",
			user_id = data.sender_user_id
			}, info_cb, {chat_id=data.chat_id,user_id=data.sender_user_id,msgid=data.id}))
		else
		end
	end
	function info_by_username(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if tonumber(data.id) then
			function info_cb(arg, data)
				if not data.id then return end
				if data.username then
					username = "@"..check_markdown(data.username)
				else
					username = ""
				end
				if data.first_name then
					firstname = check_markdown(data.first_name)
				else
					firstname = ""
				end
				if data.last_name then
					lastname = check_markdown(data.last_name)
				else
					lastname = ""
				end
				local hash = 'rank:'..arg.chat_id..':variables'
				local text = ""..Source_Start.."*نام :* `"..firstname.."`\n"..Source_Start.."*فامیلی :* `"..lastname.."`\n"..Source_Start.."*نام کاربری :* "..username.."\n"..Source_Start.."*آیدی :* `"..data.id.."`\n"
				if is_leader1(data.id) then
					text = text..Source_Start..'*مقام :* `سازنده سورس`\n'
				elseif is_sudo1(data.id) then
					text = text..Source_Start..'*مقام :* `سودو ربات`\n'
				elseif is_admin1(data.id) then
					text = text..Source_Start..'*مقام :* `ادمین ربات`\n'
				elseif is_owner1(arg.chat_id, data.id) then
					text = text..Source_Start..'*مقام :* `سازنده گروه`\n'
				elseif is_mod1(arg.chat_id, data.id) then
					text = text..Source_Start..'*مقام :* `مدیر گروه`\n'
				else
					text = text..Source_Start..'*مقام :* `کاربر عادی`\n'
				end
				local user_info = {}
				local uhash = 'user:'..data.id
				local user = redis:hgetall(RedisIndex..uhash)
				local um_hash = 'msgs:'..data.id..':'..arg.chat_id
				local gaps = 'msgs:'..arg.chat_id
				local hashss = 'laghab:'..tostring(data.id)
				laghab = redis:get(RedisIndex..hashss) or 'ثبت نشده'
				user_info_msgs = tonumber(redis:get(RedisIndex..um_hash) or 0)
				gap_info_msgs = tonumber(redis:get(RedisIndex..gaps) or 0)
				Percent_= tonumber(user_info_msgs) / tonumber(gap_info_msgs) * 100
				if Percent_ < 10 then
					Percent = '0'..string.sub(Percent_, 1, 4)
				elseif Percent_ >= 10 then
					Percent = string.sub(Percent_, 1, 5)
				end
				if tonumber(Percent) <= 10 then
					UsStatus = "ضعیف 😴"
				elseif tonumber(Percent) <= 20 then
					UsStatus = "معمولی 😊"
				elseif tonumber(Percent) <= 100 then
					UsStatus = "فعال 😎"
				end
				text = text..Source_Start..'*پیام های گروه :* `'..gap_info_msgs..'`\n'
				text = text..Source_Start..'*پیام های کاربر :* `'..user_info_msgs..'`\n'
				text = text..Source_Start..'*درصد پیام کاربر :* `('..Percent..'%)`\n'
				text = text..Source_Start..'*وضعیت کاربر :* `'..UsStatus..'`\n'
				text = text..Source_Start..'*لقب کاربر :* `'..laghab..'`'
				tdbot.sendMessage(arg.chat_id, arg.msgid, 0, text, 0, "md")
			end
			assert (tdbot_function ({
			_ = "getUser",
			user_id = data.id
			}, info_cb, {chat_id=arg.chat_id,user_id=data.id,msgid=msgid}))
		end
	end
	function info_by_id(arg, data)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if tonumber(data.id) then
			if data.username then
				username = "@"..check_markdown(data.username)
			else
				username = ""
			end
			if data.first_name then
				firstname = check_markdown(data.first_name)
			else
				firstname = ""
			end
			if data.last_name then
				lastname = check_markdown(data.last_name)
			else
				lastname = ""
			end
			local hash = 'rank:'..arg.chat_id..':variables'
			local text = ""..Source_Start.."*نام :* `"..firstname.."`\n"..Source_Start.."*فامیلی :* `"..lastname.."`\n"..Source_Start.."*نام کاربری :* "..username.."\n"..Source_Start.."*آیدی :* `"..data.id.."`\n"
			if data.id == tonumber(MahDiRoO) then
				text = text..Source_Start..'*مقام :* `سازنده سورس`\n'
			elseif is_sudo1(data.id) then
				text = text..Source_Start..'*مقام :* `سودو ربات`\n'
			elseif is_admin1(data.id) then
				text = text..Source_Start..'*مقام :* `ادمین ربات`\n'
			elseif is_owner1(arg.chat_id, data.id) then
				text = text..Source_Start..'*مقام :* `سازنده گروه`\n'
			elseif is_mod1(arg.chat_id, data.id) then
				text = text..Source_Start..'*مقام :* `مدیر گروه`\n'
			else
				text = text..Source_Start..'*مقام :* `کاربر عادی`\n'
			end
			local user_info = {}
			local uhash = 'user:'..data.id
			local user = redis:hgetall(RedisIndex..uhash)
			local um_hash = 'msgs:'..data.id..':'..arg.chat_id
			local gaps = 'msgs:'..arg.chat_id
			local hashss = 'laghab:'..tostring(data.id)
			laghab = redis:get(RedisIndex..hashss) or 'ثبت نشده'
			user_info_msgs = tonumber(redis:get(RedisIndex..um_hash) or 0)
			gap_info_msgs = tonumber(redis:get(RedisIndex..gaps) or 0)
			Percent_= tonumber(user_info_msgs) / tonumber(gap_info_msgs) * 100
			if Percent_ < 10 then
				Percent = '0'..string.sub(Percent_, 1, 4)
			elseif Percent_ >= 10 then
				Percent = string.sub(Percent_, 1, 5)
			end
			if tonumber(Percent) <= 10 then
				UsStatus = "ضعیف 😴"
			elseif tonumber(Percent) <= 20 then
				UsStatus = "معمولی 😊"
			elseif tonumber(Percent) <= 100 then
				UsStatus = "فعال 😎"
			end
			text = text..Source_Start..'*پیام های گروه :* `'..gap_info_msgs..'`\n'
			text = text..Source_Start..'*پیام های کاربر :* `'..user_info_msgs..'`\n'
			text = text..Source_Start..'*درصد پیام کاربر :* `('..Percent..'%)`\n'
			text = text..Source_Start..'*وضعیت کاربر :* `'..UsStatus..'`\n'
			text = text..Source_Start..'*لقب کاربر :* `'..laghab..'`'
			tdbot.sendMessage(arg.chat_id, arg.msgid, 0, text, 0, "md")
		end
	end
	function Lock_Delmsg(msg, stats, fa)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex..''..stats..':'..msg.chat_id) == 'Enable' then
			local rfa = Source_Start.."*قفل* `"..fa.."` *از قبل فعال بود.*"..EndMsg.."\n*حالت قفل :* `حذف پیام`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
		else
			local rfa = Source_Start.."*قفل* `"..fa.."` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *فعال شد.*"..EndMsg.."\n*حالت قفل :* `حذف پیام`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
			redis:set(RedisIndex..''..stats..':'..msg.chat_id, 'Enable')
		end
	end
	function Lock_Delmsg_warn(msg, stats, fa)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex..''..stats..':'..msg.chat_id) == 'Warn' then
			local rfa = Source_Start.."*قفل* `"..fa.."` *از قبل فعال بود.*"..EndMsg.."\n*حالت قفل :* `اخطار`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
		else
			local rfa = Source_Start.."*قفل* `"..fa.."` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *فعال شد.*"..EndMsg.."\n*حالت قفل :* `اخطار`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
			redis:set(RedisIndex..''..stats..':'..msg.chat_id, 'Warn')
		end
	end
	function Lock_Delmsg_kick(msg, stats, fa)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex..''..stats..':'..msg.chat_id) == 'Kick' then
			local rfa = Source_Start.."*قفل* `"..fa.."` *از قبل فعال بود.*"..EndMsg.."\n*حالت قفل :* `اخراج`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
		else
			local rfa = Source_Start.."*قفل* `"..fa.."` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *فعال شد.*"..EndMsg.."\n*حالت قفل :* `اخراج`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
			redis:set(RedisIndex..''..stats..':'..msg.chat_id, 'Kick')
		end
	end
	function Lock_Delmsg_mute(msg, stats, fa)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex..''..stats..':'..msg.chat_id) == 'Mute' then
			local rfa = Source_Start.."*قفل* `"..fa.."` *از قبل فعال بود.*"..EndMsg.."\n*حالت قفل :* `سکوت`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
		else
			local rfa = Source_Start.."*قفل* `"..fa.."` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *فعال شد.*"..EndMsg.."\n*حالت قفل :* `سکوت`"
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
			redis:set(RedisIndex..''..stats..':'..msg.chat_id, 'Mute')
		end
	end
	function Unlock_Delmsg(msg, stats, fa)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if redis:get(RedisIndex..''..stats..':'..msg.chat_id) then
			local rfa = Source_Start.."*قفل* `"..fa.."` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *غیرفعال شد.*"..EndMsg..""
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
			redis:del(RedisIndex..''..stats..':'..msg.chat_id)
		else
			local rfa = Source_Start.."*قفل* `"..fa.."` *از قبل فعال نبود.*"..EndMsg..""
			tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
		end
	end
	function forwardlist(msg)
		local list = redis:smembers(RedisIndex..'ForwardMsg_List')
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		message = Source_Start..'*لیست دستورات فوروارد :*\n'
		for k,v in pairs(list) do
			message = message..k.."- "..v.."\n"
		end
		if #list == 0 then
			message = Source_Start.."`در حال حاضر هیچ دستور فورواردی تنظیم نشده است`"..EndMsg
		end
		tdbot.sendMessage(msg.chat_id , msg.id, 1, message, 0, 'md')
	end
	function modlist(msg)
		local list = redis:smembers(RedisIndex..'Mods:'..msg.to.id)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if not redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
			message = Source_Start..'`گروه در` #لیست `گروه ربات  نیست`'..EndMsg
		end
		message = Source_Start..'*لیست مدیران گروه :*\n'
		for k,v in pairs(list) do
			local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
			message = message..k.."- "..v.." [" ..check_markdown(user_name).. "]\n"
		end
		if #list == 0 then
			message = Source_Start.."`در حال حاضر هیچ مدیری برای گروه انتخاب نشده است`"..EndMsg
		end
		tdbot.sendMessage(msg.chat_id , msg.id, 1, message, 0, 'md')
	end
	function banned_list(msg)
	local list = redis:smembers(RedisIndex.."Banned:"..msg.to.id)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
	if not redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
		message = Source_Start..'`گروه در` #لیست `گروه ربات  نیست`'..EndMsg
	end
	message = Source_Start..'*لیست کاربران محروم شده از گروه :*\n'
	for k,v in pairs(list) do
	local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
	message = message..k.."- "..check_markdown(user_name).." [" ..v.. "]\n" 
	end
	if #list == 0 then
	message = Source_Start.."*هیچ کاربری از این گروه محروم نشده*"..EndMsg
	end
	tdbot.sendMessage(msg.chat_id , msg.id, 1, message, 0, 'md')
end
function silent_users_list(msg)
local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
	local function GetRestricted(arg, data)
		msg=arg.msg
		local i = 1
		message = Source_Start..'*لیست کاربران میوت شده :*\n'
		local un = ''
		if data.total_count > 0 then
			i = 1
			k = 0
			local function getuser(arg, mdata)
				local ST = data.members[k].status
				if ST.can_add_web_page_previews == false and ST.can_send_media_messages == false and ST.can_send_messages == false and ST.can_send_other_messages == false and ST.is_member == true then
					if mdata.username then
						un = '@'..mdata.username
					else
						un = mdata.first_name
					end
					message = message ..i.. '-'..'' ..data.members[k].user_id.. ' - '..check_markdown(un)..'\n'
					i = i + 1
				end
				k = k + 1
				if k < data.total_count then
					tdbot.getUser(data.members[k].user_id, getuser, nil)
				else
					if i == 1 then
							return tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`لیست کاربران میوت شده خالی است`"..EndMsg, 0, "md")
					else
						return tdbot.sendMessage(msg.to.id, msg.id, 1, message, 0, "md")
					end
				end
			end
			tdbot.getUser(data.members[k].user_id, getuser, nil)
		else
				return tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`لیست کاربران میوت شده خالی است`"..EndMsg, 0, "md")
		end
	end
	tdbot.getChannelMembers(msg.chat_id, 0, 100000, 'Restricted', GetRestricted, {msg=msg})
end
	function whitelist(msg)
	local list = redis:smembers(RedisIndex.."Whitelist:"..msg.to.id)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
		message = Source_Start..'`گروه در` #لیست `گروه ربات  نیست`'..EndMsg
	end
	message = Source_Start..'`کاربران لیست ویژه :`\n'
	for k,v in pairs(list) do
	local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
	message = message..k.."- "..check_markdown(user_name).." [" ..v.. "]\n" 
	end
	if #list == 0 then
	message = Source_Start.."*هیچ کاربری در لیست ویژه وجود ندارد*"..EndMsg
	end
	tdbot.sendMessage(msg.chat_id , msg.id, 1, message, 0, 'md')
end
	function ownerlist(msg)
		local list = redis:smembers(RedisIndex..'Owners:'..msg.to.id)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		if not redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
			message = Source_Start..'`گروه در` #لیست `گروه ربات  نیست`'..EndMsg
		end
		message = Source_Start..'*لیست مالکین گروه :*\n'
		for k,v in pairs(list) do
			local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
			message = message..k.."- "..v.." [" ..check_markdown(user_name).. "]\n"
		end
		if #list == 0 then
			message = Source_Start.."`در حال حاضر هیچ مالکی برای گروه انتخاب نشده است`"..EndMsg
		end
		tdbot.sendMessage(msg.chat_id , msg.id, 1, message, 0, 'md')
	end
	function set_config(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		local function config_cb(arg, data)
			for k,v in pairs(data.members) do
				local function config_mods(arg, data)
					redis:sadd(RedisIndex..'Mods:'..msg.chat_id,data.id)
				end
				assert (tdbot_function ({
				_ = "getUser",
				user_id = v.user_id
				}, config_mods, {user_id=v.user_id}))
				
				if data.members[k].status._ == "chatMemberStatusCreator" then
					owner_id = v.user_id
					local function config_owner(arg, data)
						redis:sadd(RedisIndex..'Owners:'..msg.chat_id, data.id)
						tdbot.sendMention(msg.chat_id,data.id, msg.id,Source_Start..'با موفقیت انجام شد تمام ادمین های گروه به مدیر ربات منتصب شدند و سازنده گروه به مقام مالک گروه منتصب شد.'..EndMsg,67, tonumber(Slen("سازنده گروه")))
					end
					assert (tdbot_function ({
					_ = "getUser",
					user_id = owner_id
					}, config_owner, {user_id=owner_id}))
				end
			end
		end
		tdbot.getChannelMembers(msg.to.id, 0, 200, 'Administrators', config_cb, {chat_id=msg.to.id})
	end
	function set_configadd(msg)
		local function config_cb(arg, data)
			for k,v in pairs(data.members) do
				local function config_mods(arg, data)
					redis:sadd(RedisIndex..'Mods:'..msg.chat_id,data.id)
				end
				assert (tdbot_function ({
				_ = "getUser",
				user_id = v.user_id
				}, config_mods, {user_id=v.user_id}))
				
				if data.members[k].status._ == "chatMemberStatusCreator" then
					owner_id = v.user_id
					local function config_owner(arg, data)
						redis:sadd(RedisIndex..'Owners:'..msg.chat_id, data.id)
					end
					assert (tdbot_function ({
					_ = "getUser",
					user_id = owner_id
					}, config_owner, {user_id=owner_id}))
				end
			end
		end
		tdbot.getChannelMembers(msg.to.id, 0, 200, 'Administrators', config_cb, {chat_id=msg.to.id})
	end
	function is_JoinChannel(msg)
		local url  = https.request('https://api.telegram.org/bot'..bot_token..'/getchatmember?chat_id=@'..channel_inline..'&user_id='..msg.sender_user_id)
		if res ~= 200 then end
		local joinenabel = redis:get(RedisIndex.."JoinEnabel"..msg.chat_id)
		Joinchanel = json:decode(url)
		if (not Joinchanel.ok or Joinchanel.result.status == "left" or Joinchanel.result.status == "kicked") and not joinenabel  then
			if redis:get(RedisIndex.."BoTMode") == "CliMode" then
				local function inline_query_cb(arg, data)
					if data.results and data.results[0] then
						tdbot.sendInlineQueryResultMessage(msg.chat_id, msg.id, 0, 1, data.inline_query_id, data.results[0].id, dl_cb, nil)
					end
				end
				tdbot.getInlineQueryResults(Bot_idapi, msg.chat_id, 0, 0, "Join", 0, inline_query_cb, nil)
			else
				tdbot.sendMessage(msg.chat_id, msg.id, 1, '`₪ مدیر گرامی لطفا برای اجرای دستور شما توسط ربات در کانال ما عضو شوید 🌺`\n', 1, 'md')
			end
		else
			return true
		end
	end
	function send_req(url)
		local dat, res = https.request(url)
		local tab = JSON.decode(dat)
		if res ~= 200 then return false end
		if not tab.ok then return false end
		return tab
	end
	function send_msg(chat_id, text, markdown)
		local url = 'https://api.telegram.org/bot763855704:AAGEAKxklmaQLAUFKu6vKWTe0oS3lpAdevg/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)
		if markdown == 'md' or markdown == 'markdown' then
			url = url..'&parse_mode=Markdown'
		elseif markdown == 'html' then
			url = url..'&parse_mode=HTML'
		end
		return send_req(url)
	end
	function Core(msg)
		local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
		local Source_Start = Emoji[math.random(#Emoji)]
		local CmdMatches = msg.content.text
		if CmdMatches then
			CmdMatches = CmdMatches:lower()
		end
		local CmdMatchesL = msg.content.text
		if CmdMatchesL then
			CmdMatchesL = CmdMatchesL
		end
		if CmdMatchesL then
			if CmdMatchesL:match('^[/#!]') then
				CmdMatchesL = CmdMatchesL:gsub('^[/#!]','')
			end
		end
		if CmdMatches then
			if CmdMatches:match('^[/#!]') then
				CmdMatches = CmdMatches:gsub('^[/#!]','')
			end
		end
		if tonumber(msg.from.id) == SUDO then
			if CmdMatches == "setsudo" or CmdMatches == "تنظیم سودو" then
				ReplySet(msg,"visudo")
			elseif CmdMatches == "remsudo" or CmdMatches == "حذف سودو" then
				ReplySet(msg,"desudo")
			elseif CmdMatches and (CmdMatches:match('^setsudo (.*)') or CmdMatches:match('^تنظیم سودو (.*)')) then
				local Matches = CmdMatches:match('^setsudo (.*)') or CmdMatches:match('^تنظیم سودو (.*)')
				UseridSet(msg, Matches ,"visudo")
			elseif CmdMatches and (CmdMatches:match('^remsudo (.*)') or CmdMatches:match('^حذف سودو (.*)')) then
				local Matches = CmdMatches:match('^remsudo (.*)') or CmdMatches:match('^حذف سودو (.*)')
				UseridSet(msg, Matches ,"desudo")
			elseif CmdMatches == "cli on" then
				redis:set(RedisIndex.."BoTMode" , "CliMode")
				tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."*Cli Mode On*"..EndMsg, 1, 'md')
			elseif CmdMatches == "cli off" then
				redis:del(RedisIndex.."BoTMode")
				tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."*Cli Mode Off*"..EndMsg, 1, 'md')
			end
		end
		if is_sudo(msg) then
			if CmdMatches == 'reload' or CmdMatches == 'بروز' then
				dofile('./data/photos/Bot.lua')
				tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'*ربات بروزرسانی شد*'..EndMsg, 1, 'md')
			elseif CmdMatches == "setadmin" or CmdMatches == "تنظیم ادمین" then
				ReplySet(msg,"adminprom")
			elseif CmdMatches == "remadmin" or CmdMatches == "حذف ادمین" then
				ReplySet(msg,"admindem")
			elseif CmdMatches and (CmdMatches:match('^setadmin (.*)') or CmdMatches:match('^تنظیم ادمین (.*)')) then
				local Matches = CmdMatches:match('^setadmin (.*)') or CmdMatches:match('^تنظیم ادمین (.*)')
				UseridSet(msg, Matches ,"adminprom")
			elseif CmdMatches and (CmdMatches:match('^remadmin (.*)') or CmdMatches:match('^حذف ادمین (.*)')) then
				local Matches = CmdMatches:match('^remadmin (.*)') or CmdMatches:match('^حذف ادمین (.*)')
				UseridSet(msg, Matches ,"admindem")
			elseif CmdMatches == "sudolist" or CmdMatches == "لیست سودو" then
				return sudolist(msg)
			elseif CmdMatches == "codegift" or CmdMatches == "کدهدیه" then
				local code = {'1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
				local charge = {2,5,8,10,11,14,16,18,20}
				local a = code[math.random(#code)]
				local b = code[math.random(#code)]
				local c = code[math.random(#code)]
				local d = code[math.random(#code)]
				local e = code[math.random(#code)]
				local f = code[math.random(#code)]
				local chargetext = charge[math.random(#charge)]
				local codetext = ""..a..b..c..d..e..f..""
				redis:sadd(RedisIndex.."CodeGift:", codetext)
				redis:hset(RedisIndex.."CodeGiftt:", codetext , chargetext)
				redis:setex(RedisIndex.."CodeGiftCharge:"..codetext,chargetext * 86400,true)
				local text = Source_Start.."`کد با موفقیت ساخته شد.\nکد :`\n*"..codetext.."*\n`دارای` *"..chargetext.."* `روز شارژ میباشد .`"..EndMsg
				local text2 = Source_Start.."`کدهدیه جدید ساخته شد.`\n`¤ این کدهدیه دارای` *"..chargetext.."* `روز شارژ میباشد !`\n`¤ طرز استفاده :`\n`¤ ابتدا دستور 'gift' راوارد نماید سپس کدهدیه را وارد کنید :`\n*"..codetext.."*\n`رو در گروه خود ارسال کند ,` *"..chargetext.."* `روز شارژ به گروه آن اضافه میشود !`\n`¤¤¤ توجه فقط یک نفر میتواند از این کد استفاده کند !`"..EndMsg
				tdbot.sendMessage(msg.chat_id, msg.id, 1, text, 1, 'md')
				tdbot.sendMessage(gp_sudo, msg.id, 1, text2, 1, 'md')
			elseif CmdMatches == "giftlist" or CmdMatches == "لیست کدهدیه" then
				local list = redis:smembers(RedisIndex.."CodeGift:")
				local text = '*💢 لیست کد هدیه های ساخته شده :*\n'
				for k,v in pairs(list) do
					local expire = redis:ttl(RedisIndex.."CodeGiftCharge:"..v)
					if expire == -1 then
						EXPIRE = "نامحدود"
					else
						local d = math.floor(expire / 86400 ) + 1
						EXPIRE = d..""
					end
					text = text..k.."- `• کدهدیه :`\n[ *"..v.."* ]\n`• شارژ :`\n*"..EXPIRE.."*\n\n❦❧❦❧❦❧❦❧❦❧\n"
				end
				if #list == 0 then
					text = Source_Start..'`هیچ کد هدیه , ساخته نشده است`'..EndMsg
				end
				tdbot.sendMessage(msg.chat_id, msg.id, 1, text, 1, 'md')
			elseif CmdMatches == "full" or CmdMatches == "نامحدود" then
				local linkgp = redis:get(RedisIndex..msg.to.id..'linkgpset')
				local mods = redis:smembers(RedisIndex..'Mods:'..msg.to.id)
				local owners = redis:smembers(RedisIndex..'Owners:'..msg.to.id)
				message = '\n'
				for k,v in pairs(owners) do
					local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
					message = message ..k.. '- '..check_markdown(user_name)..' [' ..v.. '] \n'
				end
				message2 = '\n'
				for k,v in pairs(mods) do
					local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
					message2 = message2 ..k.. '- '..check_markdown(user_name)..' [' ..v.. '] \n'
				end
				if not linkgp then
					tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start..'`لطفا قبل از شارژ گروه لینک گروه را تنظیم کنید`'..EndMsg..'\n*"تنظیم لینک"\n"setlink"*', 1, 'md')
				else
					redis:set(RedisIndex..'ExpireDate:'..msg.to.id,true)
					if not redis:get(RedisIndex..'CheckExpire::'..msg.to.id) then
						redis:set(RedisIndex..'CheckExpire::'..msg.to.id,true)
					end
					tdbot.sendMessage(gp_sudo, msg.id, 1, "*♨️ گزارش \nگروهی به لیست گروه ای مدیریتی ربات اضافه شد ➕*\n\n🔺 *مشخصات شخص اضافه کننده :*\n\n_>نام ؛_ "..check_markdown(msg.from.first_name or "").."\n_>نام کاربری ؛_ @"..check_markdown(msg.from.username or "").."\n_>شناسه کاربری ؛_ `"..msg.from.id.."`\n\n🔺 *مشخصات گروه اضافه شده :*\n\n_>نام گروه ؛_ "..check_markdown(msg.to.title).."\n_>شناسه گروه ؛_ `"..msg.to.id.."`\n>_مقدار شارژ انجام داده ؛_ `نامحدود !`\n_>لینک گروه ؛_\n"..check_markdown(linkgp).."\n_>لیست مالک گروه ؛_ "..message.."\n_>لیست مدیران گروه؛_ "..message2.."\n\n🔺* دستور های پیشفرض برای گروه :*\n\n_برای وارد شدن به گروه ؛_\n/join `"..msg.to.id.."`\n_حذف گروه از گروه های ربات ؛_\n/rem `"..msg.to.id.."`\n_خارج شدن ربات از گروه ؛_\n/leave `"..msg.to.id.."`", 1, 'md')
					tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`ربات بدون محدودیت فعال شد !` *( نامحدود )*'..EndMsg, 1, 'md')
				end
			elseif CmdMatches == "delbotusername" or CmdMatches == "حذف یوزرنیم ربات" then
				tdbot.changeUsername('', dl_cb, nil)
				text = Source_Start..'*انجام شد*'..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches == "gid" or CmdMatches == "آیدی گروه" then
				tdbot.sendMessage(msg.to.id, msg.id, 1, '`'..msg.to.id..'`', 1,'md')
			elseif CmdMatches == "time sv" or CmdMatches == "ساعت سرور" then
				tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`ساعت سرور :`\n'..os.date("%H:%M:%S")..''..EndMsg, 1, 'md')
			elseif CmdMatches == "حذف شماره کارت" then
				local hash = ('cart')
				redis:del(RedisIndex..hash)
				text = Source_Start..'`نرخ ربات پاک شد`'..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches == "testspeed" or CmdMatches == "سرعت سرور" then
				local io = io.popen("speedtest --share"):read("*all")
				link = io:match("http://www.speedtest.net/result/%d+.png")
				local file = download_to_file(link,'speed.png')
				tdbot.sendPhoto(msg.to.id, msg.id, file, 0, {}, 0, 0, Source_Start..""..channel_username..""..EndMsg, 0, 0, 1, nil, dl_cb, nil)
			elseif CmdMatches and (CmdMatches:match('^charge (%d+)') or CmdMatches:match('^شارژ (%d+)')) and msg.to.type == 'channel' or msg.to.type == 'chat' then
				local Matches = CmdMatches:match('^charge (%d+)') or CmdMatches:match('^شارژ (%d+)')
				local linkgp = redis:get(RedisIndex..msg.to.id..'linkgpset')
				local mods = redis:smembers(RedisIndex..'Mods:'..msg.to.id)
				local owners = redis:smembers(RedisIndex..'Owners:'..msg.to.id)
				message = '\n'
				for k,v in pairs(owners) do
					local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
					message = message ..k.. '- '..check_markdown(user_name)..' [' ..v.. '] \n'
				end
				message2 = '\n'
				for k,v in pairs(mods) do
					local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
					message2 = message2 ..k.. '- '..check_markdown(user_name)..' [' ..v.. '] \n'
				end
				if not linkgp then
					text = Source_Start..'`لطفا قبل از شارژ گروه لینک گروه را تنظیم کنید`'..EndMsg..'\n*"تنظیم لینک"\n"setlink"*'
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif tonumber(Matches) > 0 and tonumber(Matches) < 1001 then
					local extime = (tonumber(Matches) * 86400)
					redis:setex(RedisIndex..'ExpireDate:'..msg.to.id, extime, true)
					if not redis:get(RedisIndex..'CheckExpire::'..msg.to.id) then
						redis:set(RedisIndex..'CheckExpire::'..msg.to.id)
					end
					tdbot.sendMessage(gp_sudo, msg.id, 1, "*♨️ گزارش \nگروهی به لیست گروه ای مدیریتی ربات اضافه شد ➕*\n\n🔺 *مشخصات شخص اضافه کننده :*\n\n_>نام ؛_ "..check_markdown(msg.from.first_name or "").."\n_>نام کاربری ؛_ @"..check_markdown(msg.from.username or "").."\n_>شناسه کاربری ؛_ `"..msg.from.id.."`\n\n🔺 *مشخصات گروه اضافه شده :*\n\n_>نام گروه ؛_ "..check_markdown(msg.to.title).."\n_>شناسه گروه ؛_ `"..msg.to.id.."`\n>_مقدار شارژ انجام داده ؛_ `"..Matches.."`\n_>لینک گروه ؛_\n"..check_markdown(linkgp).."\n_>لیست مالک گروه ؛_ "..message.."\n_>لیست مدیران گروه؛_ "..message2.."\n\n🔺* دستور های پیشفرض برای گروه :*\n\n_برای وارد شدن به گروه ؛_\n/join `"..msg.to.id.."`\n_حذف گروه از گروه های ربات ؛_\n/rem `"..msg.to.id.."`\n_خارج شدن ربات از گروه ؛_\n/leave `"..msg.to.id.."`", 1, 'md')
					tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`گروه به مدت` *'..Matches..'* `روز شارژ شد.`'..EndMsg, 1, 'md')
				else
					tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'*تعداد روزها باید عددی از 1 تا 1000 باشد.*'..EndMsg, 1, 'md')
				end
			elseif CmdMatches and (CmdMatches:match('^setnerkh (.*)') or CmdMatches:match('^تنظیم نرخ (.*)')) then
				local Matches = CmdMatches:match('^setnerkh (.*)') or CmdMatches:match('^تنظیم نرخ (.*)')
				redis:set(RedisIndex..'nerkh',Matches)
				text = Source_Start..'`متن شما با موفقیت تنظیم شد :`\n\n '..check_markdown(Matches)..''
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^تنظیم کارت (.*)')) then
				local Matches = CmdMatches:match('^تنظیم کارت (.*)')
				redis:set(RedisIndex..'cart',Matches)
				text = Source_Start..'`شماره کارت شما با موفقیت تنظیم شد :`\n\n '..check_markdown(Matches)..''
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^setmonshi (.*)') or CmdMatches:match('^تنظیم منشی (.*)')) then
				local Matches = CmdMatches:match('^setmonshi (.*)') or CmdMatches:match('^تنظیم منشی (.*)')
				redis:set(RedisIndex..'bot:pm',Matches)
				text = Source_Start..'`متن منشی با موفقیت ثبت شد.`\n\n>>>  '..check_markdown(Matches)..''
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches == "monshi" or CmdMatches == "منشی" then
				local hash = ('bot:pm')
				local pm = redis:get(RedisIndex..hash)
				if not pm then
					text = Source_Start..'`متن منشی ثبت نشده است.`'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				else
					tdbot.sendMessage(msg.chat_id, 0, 1, "*پیغام کنونی منشی :*\n\n"..check_markdown(pm), 0, 'md')
				end
			elseif CmdMatches and (CmdMatches:match('^monshi (.*)') or CmdMatches:match('^منشی (.*)')) then
				local CmdEn = {
				string.match(CmdMatches, "^(monshi) (.*)$")
				}
				local CmdFa = {
				string.match(CmdMatches, "^(منشی) (.*)$")
				}
				if CmdEn[2]=="on" or CmdFa[2]=="فعال" then
					redis:set(RedisIndex.."bot:pm", Source_Start.."`سلام من یک اکانت هوشمند هستم.`"..EndMsg )
					text = Source_Start.."`منشی فعال شد لطفا دوباره پیغام را تنظیم کنید`" ..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
				if CmdEn[2]=="off" or CmdFa[2]=="غیرفعال" then
					redis:del(RedisIndex.."bot:pm")
					text = Source_Start.."`منشی غیرفعال شد`" ..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
			elseif CmdMatches and (CmdMatches:match('^joinch (.*)') or CmdMatches:match('^عضویت اجباری (.*)')) then
				local CmdEn = {
				string.match(CmdMatches, "^(joinch) (.*)$")
				}
				local CmdFa = {
				string.match(CmdMatches, "^(عضویت اجباری) (.*)$")
				}
				if CmdEn[2] == "on" or CmdFa[2] == "فعال" then
					redis:del(RedisIndex.."JoinEnabel"..msg.chat_id)
					text = Source_Start.."`جوین اجباری در این گروه` #فعال `شد.`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdEn[2] == "off" or CmdFa[2] == "غیرفعال" then
					redis:set(RedisIndex.."JoinEnabel"..msg.chat_id, true)
					text = Source_Start.."`جوین اجباری در این گروه` #غیرفعال `شد.`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
			elseif CmdMatches == "add" or CmdMatches == "نصب گروه" then
				set_configadd(msg)
				modadd(msg)
			elseif CmdMatches == 'rem' or CmdMatches == "حذف گروه" then
				if redis:get(RedisIndex..'CheckExpire::'..msg.to.id) then
					redis:del(RedisIndex..'CheckExpire::'..msg.to.id)
				end
				redis:del(RedisIndex..'ExpireDate:'..msg.to.id)
				return modrem(msg)
			elseif CmdMatches and (CmdMatches:match('^leave (.*)') or CmdMatches:match('^خروج (.*)')) then
				local Matches = CmdMatches:match('^leave (.*)') or CmdMatches:match('^خروج (.*)')
				tdbot.sendMessage(Matches, 0, 1, Source_Start..'ربات با دستور سودو از گروه خارج شد.\nبرای اطلاعات بیشتر با سودو تماس بگیرید.'..EndMsg..'\n`سودو ربات :` '..check_markdown(sudo_username), 1, 'md')
				tdbot.changeChatMemberStatus(Matches, our_id, 'Left', dl_cb, nil)
				tdbot.sendMessage(gp_sudo, msg.id, 1, Source_Start..'ربات با موفقیت از گروه '..Matches..' خارج شد.'..EndMsg..'\nتوسط : @'..check_markdown(msg.from.username or '')..' | `'..msg.from.id..'`', 1,'md')
			elseif CmdMatches and (CmdMatches:match('^charge (-%d+) (%d+)') or CmdMatches:match('^شارژ (-%d+) (%d+)')) then
				local Matches = CmdMatches:match('^charge (-%d+)') or CmdMatches:match('^شارژ (-%d+)')
				local Matches2 = CmdMatches:match('^charge (-%d+) (%d+)') or CmdMatches:match('^شارژ (-%d+) (%d+)')
				if string.match(Matches, '^-%d+$') then
					if tonumber(Matches2) > 0 and tonumber(Matches2) < 1001 then
						local extime = (tonumber(Matches2) * 86400)
						redis:setex(RedisIndex..'ExpireDate:'..Matches, extime, true)
						if not redis:get(RedisIndex..'CheckExpire::'..msg.to.id) then
							redis:set(RedisIndex..'CheckExpire::'..msg.to.id,true)
						end
						tdbot.sendMessage(gp_sudo, 0, 1, "*♨️ گزارش \nگروهی به لیست گروه ای مدیریتی ربات اضافه شد ➕*\n\n🔺 *مشخصات شخص اضافه کننده :*\n\n_>نام ؛_ "..check_markdown(msg.from.first_name or "").."\n_>نام کاربری ؛_ @"..check_markdown(msg.from.username or "").."\n_>شناسه کاربری ؛_ `"..msg.from.id.."`\n\n🔺 *مشخصات گروه اضافه شده :*\n\n_>نام گروه ؛_ "..check_markdown(msg.to.title).."\n_>شناسه گروه ؛_ `"..Matches.."`\n>_مقدار شارژ انجام داده ؛_ `"..Matches2.."`\n🔺* دستور های پیشفرض برای گروه :*\n\n_برای وارد شدن به گروه ؛_\n/join `"..Matches.."`\n_حذف گروه از گروه های ربات ؛_\n/rem `"..Matches.."`\n_خارج شدن ربات از گروه ؛_\n/leave `"..Matches.."`", 1, 'md')
						tdbot.sendMessage(Matches, 0, 1, Source_Start..'ربات توسط ادمین به مدت `'..Matches2..'` روز شارژ شد\nبرای مشاهده زمان شارژ گروه دستور /expire استفاده کنید...'..EndMsg,1 , 'md')
					else
						tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'*تعداد روزها باید عددی از 1 تا 1000 باشد.*'..EndMsg, 1, 'md')
					end
				end
			elseif CmdMatches and (CmdMatches:match('^jointo (-%d+)') or CmdMatches:match('^ورود به (-%d+)')) then
				local Matches = CmdMatches:match('^jointo (-%d+)') or CmdMatches:match('^ورود به (-%d+)')
				if string.match(Matches, '^-%d+$') then
					tdbot.sendMessage(SUDO, msg.id, 1, Source_Start..'با موفقیت تورو به گروه '..Matches..' اضافه کردم.'..EndMsg, 1, 'md')
					tdbot.addChatMember(Matches, SUDO, 0, dl_cb, nil)
					tdbot.sendMessage(Matches, 0, 1, Source_Start..'*سودو به گروه اضافه شد.*'..EndMsg..'\n`سودو ربات :` '..check_markdown(sudo_username), 1, 'md')
				end
			elseif CmdMatches and (CmdMatches:match('^setbotname (.*)') or CmdMatches:match('^تغییر نام ربات (.*)')) then
				local Matches = CmdMatches:match('^setbotname (.*)') or CmdMatches:match('^تغییر نام ربات (.*)')
				tdbot.changeName(Matches, dl_cb, nil)
				text = Source_Start..'`اسم ربات تغییر کرد به :`\n*'..Matches..'*'..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^setbotusername (.*)') or CmdMatches:match('^setbotusername (.*)')) then
				local Matches = CmdMatches:match('^setbotusername (.*)') or CmdMatches:match('^setbotusername (.*)')
				tdbot.changeUsername(Matches, dl_cb, nil)
				text = Source_Start..'`یوزرنیم ربات تغییر کرد به :` \n@'..check_markdown(Matches)..''..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^markread (.*)') or CmdMatches:match('^تیک دوم (.*)')) then
				local CmdEn = {
				string.match(CmdMatches, "^(markread) (.*)$")
				}
				local CmdFa = {
				string.match(CmdMatches, "^(تیک دوم) (.*)$")
				}
				if CmdEn[2] == 'on' or CmdFa[2] == "فعال" then
					redis:set(RedisIndex..'markread','on')
					text = Source_Start..'`تیک دوم` *روشن*'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
				if CmdEn[2] == 'off' or CmdFa[2] == "غیرفعال" then
					redis:del(RedisIndex..'markread')
					text = Source_Start..'`تیک دوم` *خاموش*'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
			elseif CmdMatches and (CmdMatches:match('^setforward (.*)') or CmdMatches:match('^تنظیم فوروارد (.*)')) and msg.reply_id then
				local Matches = CmdMatches:match('^setforward (.*)') or CmdMatches:match('^تنظیم فوروارد (.*)')
				if redis:get(RedisIndex.."ForwardMsg_Cmd"..Matches) then
					tdbot.sendMessage(msg.chat_id , msg.id, 1, "*دستور* `'"..Matches.."'` *از قبل در لیست فوروارد وجود داشت*", 0, 'md')
				end
				redis:set(RedisIndex.."ForwardMsg_Cmd"..Matches, Matches)
				redis:set(RedisIndex..'ForwardMsg_Reply'..Matches, msg.reply_id)
				redis:set(RedisIndex..'ForwardMsg_Gp'..Matches, msg.chat_id)
				redis:sadd(RedisIndex.."ForwardMsg_List", Matches)
				tdbot.sendMessage(msg.chat_id , msg.id, 1, "*پیامی که روی آن ریپلای کردید توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *روی دستور* `'"..Matches.."'` *تنظیم شد*", 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^delforward (.*)') or CmdMatches:match('^حذف فوروارد (.*)')) then
				local Matches = CmdMatches:match('^delforward (.*)') or CmdMatches:match('^حذف فوروارد (.*)')
				if not redis:get(RedisIndex.."ForwardMsg_Cmd"..Matches) then
					tdbot.sendMessage(msg.chat_id , msg.id, 1, "*دستور* `'"..Matches.."'` *در لیست فوروارد وجود ندارد*", 0, 'md')
				end
				redis:del(RedisIndex.."ForwardMsg_Cmd"..Matches)
				redis:del(RedisIndex..'ForwardMsg_Reply'..Matches)
				redis:del(RedisIndex..'ForwardMsg_Gp'..Matches)
				redis:srem(RedisIndex.."ForwardMsg_List", Matches)
				tdbot.sendMessage(msg.chat_id , msg.id, 1, "*دستور* `'"..Matches.."'` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *از لیست فوروارد حذف شد*", 0, 'md')
			elseif CmdMatches == "forwardlist" or CmdMatches == "لیست فوروارد" then
				forwardlist(msg)
			end
		end
		if CmdMatches and (CmdMatches:match('^clean (.*)') or CmdMatches:match('^پاکسازی (.*)')) and is_JoinChannel(msg) then
			local CmdEn = {
			string.match(CmdMatches, "^(clean) (.*)$")
			}
			local CmdFa = {
			string.match(CmdMatches, "^(پاکسازی) (.*)$")
			}
			if is_sudo(msg) then
				if CmdEn[2] == 'gbans' or CmdFa[2] == 'لیست سوپر مسدود' then
					local list = redis:smembers(RedisIndex..'GBanned')
					if #list == 0 then
						text = Source_Start.."*هیچ کاربری از گروه های ربات محروم نشده*"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					redis:del(RedisIndex..'GBanned')
					text = Source_Start.."*تمام کاربرانی که از گروه های ربات محروم بودند از محرومیت خارج شدند*"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
			end
			if is_admin(msg) then
				if CmdEn[2] == 'owners' or CmdFa[2] == "مالکان" then
					local list = redis:smembers(RedisIndex..'Owners:'..msg.to.id)
					if #list == 0 then
						text = Source_Start.."`مالکی برای گروه انتخاب نشده است`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					redis:del(RedisIndex.."Owners:"..msg.to.id)
					text = Source_Start.."`تمامی مالکان گروه تنزیل مقام شدند`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
			end
			if is_owner(msg) then
				if msg.to.type == "channel" then
					if CmdEn[2] == 'blacklist' or CmdFa[2] == 'لیست سیاه' then
						local function GetRestricted(arg, data)
							if data.members then
								for k,v in pairs (data.members) do
									tdbot.changeChaargemberStatus(msg.to.id, v.user_id, 'Restricted', {1,0,1,1,1,1}, dl_cb, nil)
								end
							end
						end
						local function GetBlackList(arg, data)
							if data.members then
								for k,v in pairs (data.members) do
									channel_unblock(msg.to.id, v.user_id)
								end
							end
						end
						for i = 1, 2 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Restricted', GetRestricted, {msg=msg})
						end
						for i = 1, 2 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Banned', GetBlackList, {msg=msg})
						end
						return tdbot.sendMessage(msg.to.id, msg.id, 0, Source_Start.."`لیست سیاه گروه پاک سازی شد`"..EndMsg, 0, "md")
					elseif CmdEn[2] == 'bots' or CmdFa[2] == 'ربات ها' then
						local function GetBots(arg, data)
							if data.members then
								for k,v in pairs (data.members) do
									if not is_mod1(msg.to.id, v.user_id) then
										kick_user(v.user_id, msg.to.id)
									end
								end
							end
						end
						for i = 1, 5 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Bots', GetBots, {msg=msg})
						end
						return tdbot.sendMessage(msg.to.id, msg.id, 0, Source_Start.."`تمام ربات ها از گروه حذف شدند`"..EndMsg, 0, "md")
					elseif CmdEn[2] == 'deleted' or CmdFa[2] == 'اکانت های دلیت شده' then
						local function GetDeleted(arg, data)
							if data.members then
								for k,v in pairs (data.members) do
									local function GetUser(arg, data)
										if data.type and data.type._ == "userTypeDeleted" then
											kick_user(data.id, msg.to.id)
										end
									end
									tdbot.getUser(v.user_id, GetUser, {msg=arg.msg})
								end
							end
						end
						for i = 1, 2 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Recent', GetDeleted, {msg=msg})
						end
						for i = 1, 1 do
							tdbot.getChannelMembers(msg.to.id, 0, 100000000000, 'Search', GetDeleted, {msg=msg})
						end
						return tdbot.sendMessage(msg.to.id, msg.id, 0, Source_Start.."`تمام اکانت های دلیت ‌شده از گروه حذف شدند`"..EndMsg, 0, "md")
					end
				end
				if msg.to.type ~= 'pv' then
					if CmdEn[2] == 'bans' or CmdFa[2] == 'لیست مسدود' then
						local list = redis:smembers(RedisIndex..'Banned:'..msg.to.id)
						if #list == 0 then
							text = Source_Start.."*هیچ کاربری از این گروه محروم نشده*"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						end
						redis:del(RedisIndex.."Banned:"..msg.to.id)
						text = Source_Start.."*تمام کاربران محروم شده از گروه از محرومیت خارج شدند*"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					elseif CmdEn[2] == 'silentlist' or CmdFa[2] == 'لیست سکوت' then
						local function GetRestricted(arg, data)
							msg=arg.msg
							local i = 1
							local un = ''
							if data.total_count > 0 then
								i = 1
								k = 0
								local function getuser(arg, mdata)
									local ST = data.members[k].status
									if ST.can_add_web_page_previews == false and ST.can_send_media_messages == false and ST.can_send_messages == false and ST.can_send_other_messages == false and ST.is_member == true then
										unsilent_user(msg.to.id, data.members[k].user_id)
										i = i + 1
									end
									k = k + 1
									if k < data.total_count then
										tdbot.getUser(data.members[k].user_id, getuser, nil)
									else
										if i == 1 then
											return tdbot.sendMessage(msg.to.id, msg.id, 0, "*لیست کاربران سایلنت شده خالی است*", 0, "md")
										else
											return tdbot.sendMessage(msg.to.id, msg.id, 0, "*لیست کاربران سایلنت شده پاک شد*", 0, "md")
										end
									end
								end
								tdbot.getUser(data.members[k].user_id, getuser, nil)
							else
								return tdbot.sendMessage(msg.to.id, msg.id, 0, "*لیست کاربران سایلنت شده خالی است*", 0, "md")
							end
						end
						tdbot.getChannelMembers(msg.to.id, 0, 100000, 'Restricted', GetRestricted, {msg=msg})
					end
				end
				if CmdEn[2] == 'msgs' or CmdFa[2] == 'پیام ها' then
					local function pro(arg,data)
						for k,v in pairs(data.members) do
							tdbot.deleteMessagesFromUser(msg.chat_id, v.user_id, dl_cb, nil)
						end
					end
					local function cb(arg,data)
						for k,v in pairs(data.messages) do
							del_msg(msg.chat_id, v.id)
						end
					end
					for i = 1, 5 do
						tdbot.getChatHistory(msg.to.id, msg.id, 0,  500000000, 0, cb, nil)
					end
					for i = 1, 2 do
						tdbot.getChannelMembers(msg.to.id, 0, 20000, "Search", pro, nil)
					end
					for i = 1, 1 do
						tdbot.getChannelMembers(msg.to.id, 0, 200000, "Recent", pro, nil)
					end
					for i = 1, 5 do
						tdbot.getChannelMembers(msg.to.id, 0, 2000000000, "Banned", pro, nil)
					end
					text = Source_Start.."*درحال پاکسازی پیام های گروه*"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdEn[2] == 'mods' or CmdFa[2] == "مدیران" then
					local list = redis:smembers(RedisIndex..'Mods:'..msg.to.id)
					if #list == 0 then
						text = Source_Start.."هیچ مدیری برای گروه انتخاب نشده است"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					redis:del(RedisIndex.."Mods:"..msg.to.id)
					text = Source_Start.."`تمام مدیران گروه تنزیل مقام شدند`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdEn[2] == 'filterlist' or CmdFa[2] == "لیست فیلتر" then
					local names = redis:hkeys(RedisIndex..'filterlist:'..msg.to.id)
					if #names == 0 then
						text = Source_Start.."`لیست کلمات فیلتر شده خالی است`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					redis:del(RedisIndex..'filterlist:'..msg.to.id)
					text = Source_Start.."`لیست کلمات فیلتر شده پاک شد`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdEn[2] == 'rules' or CmdFa[2] == "قوانین" then
					if not redis:get(RedisIndex..msg.to.id..'rules')then
						text = Source_Start.."`قوانین برای گروه ثبت نشده است`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					redis:del(RedisIndex..msg.to.id..'rules')
					text = Source_Start.."`قوانین گروه پاک شد`"
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdEn[2] == 'welcome' or CmdFa[2] == "خوشامد" then
					if not redis:get(RedisIndex..'setwelcome:'..msg.chat_id) then
						text = Source_Start.."`پیام خوشآمد گویی ثبت نشده است`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					redis:del(RedisIndex..'setwelcome:'..msg.chat_id)
					text = Source_Start.."`پیام خوشآمد گویی پاک شد`"
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdEn[2] == 'about' or CmdFa[2] == "درباره" then
					if msg.to.type == "chat" then
						if not redis:get(RedisIndex..msg.to.id..'about') then
							text = Source_Start.."`پیامی مبنی بر درباره گروه ثبت نشده است`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						end
					elseif msg.to.type == "channel" then
						tdbot.changeChannelDescription(chat, "", dl_cb, nil)
					end
					text = Source_Start.."`پیام مبنی بر درباره گروه پاک شد`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif  CmdEn[2] == 'warns' or CmdFa[2] == 'اخطار ها' then
					local hash = msg.to.id..':warn'
					redis:del(RedisIndex..hash)
					text = Source_Start.."`تمام اخطار های کاربران این گروه پاک شد`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				end
			end
		end
		if is_admin(msg) then
			if CmdMatches == "gban" or CmdMatches == "سوپر مسدود" then
				ReplySet(msg,"banall")
			elseif CmdMatches == "ungban" or CmdMatches == "حذف سوپر مسدود" then
				ReplySet(msg,"unbanall")
			elseif CmdMatches == "setowner" or CmdMatches == 'مالک' then
				ReplySet(msg,"setowner")
			elseif CmdMatches == "remowner" or CmdMatches == "حذف مالک" then
				ReplySet(msg,"remowner")
			elseif CmdMatches and (CmdMatches:match('^gban (.*)') or CmdMatches:match('^سوپر مسدود (.*)')) then
				local Matches = CmdMatches:match('^gban (.*)') or CmdMatches:match('^سوپر مسدود (.*)')
				UseridSet(msg, Matches ,"banall")
			elseif CmdMatches and (CmdMatches:match('^ungban (.*)') or CmdMatches:match('^حذف سوپر مسدود (.*)')) then
				local Matches = CmdMatches:match('^ungban (.*)') or CmdMatches:match('^حذف سوپر مسدود (.*)')
				UseridSet(msg, Matches ,"unbanall")
			elseif CmdMatches and (CmdMatches:match('^setowner (.*)') or CmdMatches:match('^مالک (.*)')) then
				local Matches = CmdMatches:match('^setowner (.*)') or CmdMatches:match('^مالک (.*)')
				UseridSet(msg, Matches ,"setowner")
			elseif CmdMatches and (CmdMatches:match('^remowner (.*)') or CmdMatches:match('^حذف مالک (.*)')) then
				local Matches = CmdMatches:match('^remowner (.*)') or CmdMatches:match('^حذف مالک (.*)')
				UseridSet(msg, Matches ,"remowner")
			elseif CmdMatches == "adminlist" or CmdMatches == "لیست ادمین" then
				return adminlist(msg)
			elseif CmdMatches == "leave" or CmdMatches == "خروج" then
				tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`ربات با موفقیت از گروه خارج شد.`'..EndMsg, 1,'md')
				tdbot.changeChatMemberStatus(msg.to.id, our_id, 'Left', dl_cb, nil)
			elseif CmdMatches == "chats" or CmdMatches == "لیست گروه ها" then
				return chat_list(msg)
			elseif CmdMatches == "config" or CmdMatches == "پیکربندی" then
				return set_config(msg)
			elseif CmdMatches == "tosuper" or CmdMatches == "تبدیل به سوپرگروه" then
				local id = msg.to.id
				tdbot.migrateGroupChatToChannelChat(id, dl_cb, nil)
				text = Source_Start..'`گروه به سوپر گروه تبدیل شد`'..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^setrank (.*)') or CmdMatches:match('^setrank (.*)')) then
				if msg.reply_id then
					assert (tdbot_function ({
					_ = "getMessage",
					chat_id = msg.to.id,
					message_id = msg.reply_id
					}, rank_reply, {chat_id=msg.to.id,cmd="setrank",rank=string.sub(msg.text,9)}))
				end
			elseif CmdMatches and (CmdMatches:match('^تنظیم مقام (.*)') or CmdMatches:match('^تنظیم مقام (.*)')) then
				if msg.reply_id then
					assert (tdbot_function ({
					_ = "getMessage",
					chat_id = msg.to.id,
					message_id = msg.reply_id
					}, rank_reply, {chat_id=msg.to.id,cmd="setrank",rank=string.sub(msg.text,21)}))
				end
			elseif CmdMatches == "remrank" or CmdMatches == "حذف مقام" then
				if msg.reply_id then
					assert (tdbot_function ({
					_ = "getMessage",
					chat_id = msg.to.id,
					message_id = msg.reply_id
					}, rank_reply, {chat_id=msg.to.id,cmd="delrank"}))
				end
			elseif CmdMatches and (CmdMatches:match('^setrank (.*) (.*)')) then
				local CmdEn = {
				string.match(CmdMatches, "^(setrank) (.*) (.*)")
				}
				local Matches = CmdEn[2]
				local Matches2 = CmdEn[3]
				if Matches2 and string.match(Matches2, '^%d+$') then
					assert (tdbot_function ({
					_ = "getUser",
					user_id = Matches2,
					}, rank_id, {chat_id=msg.to.id,user_id=Matches2,cmd="setrank",rank=Matches}))
				elseif Matches2 and not string.match(Matches2, '^%d+$') then
					assert (tdbot_function ({
					_ = "searchPublicChat",
					username = Matches2
					}, rank_username, {chat_id=msg.to.id,username=Matches2,cmd="setrank",rank=Matches}))
				end
			elseif CmdMatches and (CmdMatches:match('^تنظیم مقام (.*) (.*)')) then
				local CmdEn = {
				string.match(CmdMatches, "^(تنظیم مقام) (.*) (.*)")
				}
				local Matches = CmdEn[2]
				local Matches2 = CmdEn[3]
				if Matches2 and string.match(Matches2, '^%d+$') then
					assert (tdbot_function ({
					_ = "getUser",
					user_id = Matches2,
					}, rank_id, {chat_id=msg.to.id,user_id=Matches2,cmd="setrank",rank=Matches}))
				elseif Matches2 and not string.match(Matches2, '^%d+$') then
					assert (tdbot_function ({
					_ = "searchPublicChat",
					username = Matches2
					}, rank_username, {chat_id=msg.to.id,username=Matches2,cmd="setrank",rank=Matches}))
				end
			elseif CmdMatches and (CmdMatches:match('^remrank (.*)') or CmdMatches:match('^حذف مقام (.*)')) then
				local Matches = CmdMatches:match('^remrank (.*)') or CmdMatches:match('^حذف مقام (.*)')
				if Matches and string.match(Matches, '^%d+$') then
					assert (tdbot_function ({
					_ = "getUser",
					user_id = Matches,
					}, rank_id, {chat_id=msg.to.id,user_id=Matches,cmd="delrank"}))
				elseif Matches and not string.match(Matches, '^%d+$') then
					assert (tdbot_function ({
					_ = "searchPublicChat",
					username = Matches
					}, rank_username, {chat_id=msg.to.id,username=Matches,cmd="delrank"}))
				end
			elseif CmdMatches and (CmdMatches:match('^creategroup (.*)') or CmdMatches:match('^ساخت گروه (.*)')) then
				local Matches = CmdMatches:match('^creategroup (.*)') or CmdMatches:match('^ساخت گروه (.*)')
				local text = Matches
				tdbot.createNewGroupChat({[0] = msg.from.id}, text, dl_cb, nil)
				text = Source_Start..'`گروه ساخته شد`'..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^createsuper (.*)') or CmdMatches:match('^ساخت سوپرگروه (.*)')) then
				local Matches = CmdMatches:match('^createsuper (.*)') or CmdMatches:match('^ساخت سوپرگروه (.*)')
				local text = Matches
				tdbot.createNewChannelChat(text, 1, '@L_U_A_TeaM', (function(b, d) tdbot.addChatMember(d.id, msg.from.id, 0, dl_cb, nil) end), nil)
					text = Source_Start..'*سوپرگروه ساخته شد و* [`'..msg.from.id..'`] *به گروه اضافه شد.*'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^import (.*)') or CmdMatches:match('^ورود لینک (.*)')) then
					local Matches = CmdMatches:match('^import (.*)') or CmdMatches:match('^ورود لینک (.*)')
					if Matches:match("^([https?://w]*.?telegram.me/joinchat/.*)$") or Matches:match("^([https?://w]*.?t.me/joinchat/.*)$") then
						local link = Matches
						if link:match('t.me') then
							link = string.gsub(link, 't.me', 'telegram.me')
						end
						tdbot.importChatInviteLink(link, dl_cb, nil)
						text = Source_Start..'*انجام شد*'..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^join (-%d+)') or CmdMatches:match('^ورود (-%d+)')) then
					local Matches = CmdMatches:match('^join (-%d+)') or CmdMatches:match('^ورود (-%d+)')
					tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'*شما وارد گروه * '..Matches..' *شدید*'..EndMsg, 1, 'md')
					tdbot.sendMessage(Matches, 0, 1, Source_Start.."*سودو ربات وارد گروه شد*"..EndMsg, 1, 'md')
					tdbot.addChatMember(Matches, msg.from.id, 0, dl_cb, nil)
				elseif CmdMatches and (CmdMatches:match('^autoleave (.*)') or CmdMatches:match('^خروج خودکار (.*)')) then
					local CmdEn = {
					string.match(CmdMatches, "^(autoleave) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(خروج خودکار) (.*)$")
					}
					local hash = 'auto_leave_bot'
					if CmdEn[2] == 'enable' or CmdFa[2] == "فعال" then
						redis:del(RedisIndex..hash)
						text = Source_Start..'*خروج خودکار فعال شد*'..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					elseif CmdEn[2] == 'disable' or CmdFa[2] == "غیرفعال" then
						redis:set(RedisIndex..hash, true)
						text = Source_Start..'*خروج خودکار غیرفعال شد*'..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^expire (-%d+)') or CmdMatches:match('^اعتبار (-%d+)')) then
					local Matches = CmdMatches:match('^expire (-%d+)') or CmdMatches:match('^اعتبار (-%d+)')
					if string.match(Matches, '^-%d+$') then
						local check_time = redis:ttl(RedisIndex..'ExpireDate:'..Matches)
						year = math.floor(check_time / 31536000)
						byear = check_time % 31536000
						month = math.floor(byear / 2592000)
						bmonth = byear % 2592000
						day = math.floor(bmonth / 86400)
						bday = bmonth % 86400
						hours = math.floor( bday / 3600)
						bhours = bday % 3600
						min = math.floor(bhours / 60)
						sec = math.floor(bhours % 60)
						if check_time == -1 then
							remained_expire = Source_Start..'`گروه به صورت نامحدود شارژ میباشد!`'..EndMsg
						elseif tonumber(check_time) > 1 and check_time < 60 then
							remained_expire = Source_Start..'`گروه به مدت` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
						elseif tonumber(check_time) > 60 and check_time < 3600 then
							remained_expire = Source_Start..'`گروه به مدت` *'..min..'* `دقیقه و` *'..sec..'* _ثانیه شارژ میباشد`'..EndMsg
						elseif tonumber(check_time) > 3600 and tonumber(check_time) < 86400 then
							remained_expire = Source_Start..'`گروه به مدت` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
						elseif tonumber(check_time) > 86400 and tonumber(check_time) < 2592000 then
							remained_expire = Source_Start..'`گروه به مدت` *'..day..'* `روز و` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
						elseif tonumber(check_time) > 2592000 and tonumber(check_time) < 31536000 then
							remained_expire = Source_Start..'`گروه به مدت` *'..month..'* `ماه` *'..day..'* `روز و` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
						elseif tonumber(check_time) > 31536000 then
							remained_expire = Source_Start..'`گروه به مدت` *'..year..'* `سال` *'..month..'* `ماه` *'..day..'* `روز و` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
						end
						tdbot.sendMessage(msg.to.id, msg.id, 1, remained_expire, 1, 'md')
					end
				elseif CmdMatches == "gbanlist" or CmdMatches == "لیست سوپر مسدود" then
					return gbanned_list(msg)
				end
			end
			if is_owner(msg) then
				if msg.text then
					local is_link = msg.text:match("^([https?://w]*.?telegram.me/joinchat/%S+)$") or msg.text:match("^([https?://w]*.?t.me/joinchat/%S+)$")
					if is_link and redis:get(RedisIndex..msg.to.id..'linkgp') then
						redis:set(RedisIndex..msg.to.id..'linkgpset', msg.text)
						text = Source_Start.."`لینک جدید ذخیره شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				end
				if (CmdMatches == "promote" or CmdMatches == "مدیر") and is_JoinChannel(msg) then
					ReplySet(msg,"promote")
				elseif (CmdMatches == "demote" or CmdMatches == "حذف مدیر") and is_JoinChannel(msg) then
					ReplySet(msg,"demote")
				elseif CmdMatches and (CmdMatches:match('^promote (.*)') or CmdMatches:match('^مدیر (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^promote (.*)') or CmdMatches:match('^مدیر (.*)')
					UseridSet(msg, Matches ,"promote")
				elseif CmdMatches and (CmdMatches:match('^demote (.*)') or CmdMatches:match('^حذف مدیر (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^demote (.*)') or CmdMatches:match('^حذف مدیر (.*)')
					UseridSet(msg, Matches ,"demote")
				elseif (CmdMatches == 'setlink' or CmdMatches == "تنظیم لینک") and is_JoinChannel(msg) then
					redis:setex(RedisIndex..msg.to.id..'linkgp', 60, true)
					text = Source_Start..'`لطفا لینک گروه خود را ارسال کنید`'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^setmute (%d+)') or CmdMatches:match('^تنظیم سکوت (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setmute (%d+)') or CmdMatches:match('^تنظیم سکوت (%d+)')
					local time = Matches * 60
					redis:set(RedisIndex.."TimeMuteset"..msg.to.id, time)
					text = Source_Start.."`زمان سکوت روی` *"..Matches.."* `دقیقه تنظیم شد`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches == "expire" or CmdMatches == "اعتبار" and msg.to.type == 'channel' or msg.to.type == 'chat' then
					local check_time = redis:ttl(RedisIndex..'ExpireDate:'..msg.to.id)
					year = math.floor(check_time / 31536000)
					byear = check_time % 31536000
					month = math.floor(byear / 2592000)
					bmonth = byear % 2592000
					day = math.floor(bmonth / 86400)
					bday = bmonth % 86400
					hours = math.floor( bday / 3600)
					bhours = bday % 3600
					min = math.floor(bhours / 60)
					sec = math.floor(bhours % 60)
					if check_time == -1 then
						remained_expire = Source_Start..'`گروه به صورت نامحدود شارژ میباشد!`'..EndMsg
					elseif tonumber(check_time) > 1 and check_time < 60 then
						remained_expire = Source_Start..'`گروه به مدت` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
					elseif tonumber(check_time) > 60 and check_time < 3600 then
						remained_expire = Source_Start..'`گروه به مدت` *'..min..'* `دقیقه و` *'..sec..'* _ثانیه شارژ میباشد`'..EndMsg
					elseif tonumber(check_time) > 3600 and tonumber(check_time) < 86400 then
						remained_expire = Source_Start..'`گروه به مدت` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
					elseif tonumber(check_time) > 86400 and tonumber(check_time) < 2592000 then
						remained_expire = Source_Start..'`گروه به مدت` *'..day..'* `روز و` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
					elseif tonumber(check_time) > 2592000 and tonumber(check_time) < 31536000 then
						remained_expire = Source_Start..'`گروه به مدت` *'..month..'* `ماه` *'..day..'* `روز و` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
					elseif tonumber(check_time) > 31536000 then
						remained_expire = Source_Start..'`گروه به مدت` *'..year..'* `سال` *'..month..'* `ماه` *'..day..'* `روز و` *'..hours..'* `ساعت و` *'..min..'* `دقیقه و` *'..sec..'* `ثانیه شارژ میباشد`'..EndMsg
					end
					tdbot.sendMessage(msg.to.id, msg.id, 1, remained_expire, 1, 'md')
				elseif (CmdMatches == "gift" or CmdMatches == "استفاده هدیه") and is_JoinChannel(msg) then
					redis:setex(RedisIndex.."Codegift:" .. msg.to.id , 260, true)
					tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."`شما دو دقیقه برای استفاده از کدهدیه زمان دارید.`"..EndMsg, 1, 'md')
				elseif (CmdMatches == "mutelist" or CmdMatches == "لیست سکوت") and is_JoinChannel(msg) then
					return silent_users_list(msg)
				elseif (CmdMatches == "banlist" or CmdMatches == "لیست مسدود") and is_JoinChannel(msg) then
					return banned_list(msg)
				elseif (CmdMatches == "ownerlist" or CmdMatches == "لیست مالکان") and is_JoinChannel(msg) then
					return ownerlist(msg)
				elseif CmdMatches and (CmdMatches:match('^flood (.*)') or CmdMatches:match('^پیام مکرر (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(flood) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(پیام مکرر ) (.*)$")
					}
					if CmdEn[2] == "mute" or CmdFa[2] == "سکوت" then
						redis:set(RedisIndex..msg.to.id..'floodmod', "Mute")
						tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."*پیام های مکرر توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *روی حالت سکوت تنظیم شد*"..EndMsg, 1, 'md')
					elseif CmdEn[2] == "kick" or CmdFa[2] == "اخراج" then
						redis:del(RedisIndex..msg.to.id..'floodmod')
						tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."*پیام های مکرر توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *روی حالت اخراج تنظیم شد*"..EndMsg, 1, 'md')
					end
				end
			end
			if is_mod(msg) then
				if msg.to.type ~= 'pv' then
					if (CmdMatches == "kick" or CmdMatches == "اخراج") and is_JoinChannel(msg) then
						ReplySet(msg,"kick")
					elseif (CmdMatches == "delall" or CmdMatches == "حذف پیام") and is_JoinChannel(msg) then
						ReplySet(msg,"delall")
					elseif (mdMatches == "ban" or CmdMatches == "مسدود") and is_JoinChannel(msg) then
						ReplySet(msg,"ban")
					elseif (CmdMatches == "unban" or CmdMatches == "حذف مسدود") and is_JoinChannel(msg) then
						ReplySet(msg,"unban")
					elseif (CmdMatches == "mute" or CmdMatches == "سکوت") and is_JoinChannel(msg) then
						ReplySet(msg,"silent")
					elseif (CmdMatches == "unmute" or CmdMatches == "حذف سکوت") and is_JoinChannel(msg) then
						ReplySet(msg,"unsilent")
					elseif CmdMatches and (CmdMatches:match('^kick (.*)') or CmdMatches:match('^اخراج (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^kick (.*)') or CmdMatches:match('^اخراج (.*)')
						UseridSet(msg, Matches ,"kick")
					elseif CmdMatches and (CmdMatches:match('^delall (.*)') or CmdMatches:match('^حذف پیام (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^delall (.*)') or CmdMatches:match('^حذف پیام (.*)')
						UseridSet(msg, Matches ,"delall")
					elseif CmdMatches and (CmdMatches:match('^ban (.*)') or CmdMatches:match('^مسدود (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^ban (.*)') or CmdMatches:match('^مسدود (.*)')
						UseridSet(msg, Matches ,"ban")
					elseif CmdMatches and (CmdMatches:match('^unban (.*)') or CmdMatches:match('^حذف مسدود (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^unban (.*)') or CmdMatches:match('^حذف مسدود (.*)')
						UseridSet(msg, Matches ,"unban")
					elseif CmdMatches and (CmdMatches:match('^mute (.*)') or CmdMatches:match('^سکوت (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^mute (.*)') or CmdMatches:match('^سکوت (.*)')
						UseridSet(msg, Matches ,"silent")
					elseif CmdMatches and (CmdMatches:match('^unmute (.*)') or CmdMatches:match('^حذف سکوت (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^unmute (.*)') or CmdMatches:match('^حذف سکوت (.*)')
						UseridSet(msg, Matches ,"unsilent")
					end
				end
				if CmdMatches and (CmdMatches:match('^warn (.*)') or CmdMatches:match('^اخطار (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(warn) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(اخطار) (.*)$")
					}
					if CmdEn[2] == "link" or CmdFa[2] == "لینک" then
						Lock_Delmsg_warn(msg, 'lock_link', "لینک")
					elseif CmdEn[2] == "tag" or CmdFa[2] == "تگ" then
						Lock_Delmsg_warn(msg, "lock_tag", "تگ")
					elseif CmdEn[2] == "views" or CmdFa[2] == "ویو" then
						Lock_Delmsg_warn(msg, "lock_views", "ویو")
					elseif CmdEn[2] == "username" or CmdFa[2] == "نام کاربری" then
						Lock_Delmsg_warn(msg, "lock_username", "نام کاربری")
					elseif CmdEn[2] == "mention" or CmdFa[2] == "منشن" then
						Lock_Delmsg_warn(msg, "lock_mention", "منشن")
					elseif CmdEn[2] == "farsi" or CmdFa[2] == "فارسی" then
						Lock_Delmsg_warn(msg, "lock_arabic", "فارسی")
					elseif CmdEn[2] == "english" or CmdFa[2] == "انگلیسی" then
						Lock_Delmsg_warn(msg, "lock_english", "انگلیسی")
					elseif CmdEn[2] == "edit" or CmdFa[2] == "ویرایش" then
						Lock_Delmsg_warn(msg, "lock_edit", "ویرایش")
					elseif CmdEn[2] == "markdown" or CmdFa[2] == "فونت" then
						Lock_Delmsg_warn(msg, "lock_markdown", "فونت")
					elseif CmdEn[2] == "webpage" or CmdFa[2] == "وب" then
						Lock_Delmsg_warn(msg, "lock_webpage", "وب")
					elseif CmdEn[2] == "gif" or CmdFa[2] == "گیف" then
						Lock_Delmsg_warn(msg, "mute_gif", "گیف")
					elseif CmdEn[2] == "text" or CmdFa[2] == "متن" then
						Lock_Delmsg_warn(msg, "mute_text", "متن")
					elseif CmdEn[2] == "photo" or CmdFa[2] == "عکس" then
						Lock_Delmsg_warn(msg, "mute_photo", "عکس")
					elseif CmdEn[2] == "video" or CmdFa[2] == "فیلم" then
						Lock_Delmsg_warn(msg, "mute_video", "فیلم")
					elseif CmdEn[2] == "video_note" or CmdFa[2] == "فیلم سلفی" then
						Lock_Delmsg_warn(msg, "mute_video_note", "فیلم سلفی")
					elseif CmdEn[2] == "audio" or CmdFa[2] == "اهنگ" then
						Lock_Delmsg_warn(msg, "mute_audio", "آهنگ")
					elseif CmdEn[2] == "voice" or CmdFa[2] == "صدا" then
						Lock_Delmsg_warn(msg, "mute_voice", "صدا")
					elseif CmdEn[2] == "sticker" or CmdFa[2] == "استیکر" then
						Lock_Delmsg_warn(msg, "mute_sticker", "استیکر")
					elseif CmdEn[2] == "contact" or CmdFa[2] == "مخاطب" then
						Lock_Delmsg_warn(msg, "mute_contact", "مخاطب")
					elseif CmdEn[2] == "forward" or CmdFa[2] == "فوروارد کانال" then
						Lock_Delmsg_warn(msg, "mute_forward", "فوروارد کانال")
					elseif CmdEn[2] == "forward user" or CmdFa[2] == "فوروارد کاربر" then
						Lock_Delmsg_warn(msg, "mute_forwarduser", "فوروارد کاربر")
					elseif CmdEn[2] == "location" or CmdFa[2] == "موقعیت" then
						Lock_Delmsg_warn(msg, "mute_location", "موقعیت")
					elseif CmdEn[2] == "document" or CmdFa[2] == "فایل" then
						Lock_Delmsg_warn(msg, "mute_document", "فایل")
					elseif CmdEn[2] == "inline" or CmdFa[2] == "کیبورد شیشه ای" then
						Lock_Delmsg_warn(msg, "mute_inline", "کیبورد شیشه ای")
					elseif CmdEn[2] == "game" or CmdFa[2] == "بازی" then
						Lock_Delmsg_warn(msg, "mute_game", "بازی")
					elseif CmdEn[2] == "keyboard" or CmdFa[2] == "صفحه کلید" then
						Lock_Delmsg_warn(msg, "mute_keyboard", "صفحه کلید")
					end
					end
				if (CmdMatches == "setvip" or CmdMatches == "ویژه") and is_JoinChannel(msg) then
					ReplySet(msg,"setwhitelist")
				elseif (CmdMatches == "remvip" or CmdMatches == "حذف ویژه") and is_JoinChannel(msg) then
					ReplySet(msg,"remwhitelist")
				elseif (CmdMatches == "warn" or CmdMatches == "اخطار") and is_JoinChannel(msg) then
					ReplySet(msg,"warn")
				elseif (CmdMatches == "unwarn" or CmdMatches == "حذف اخطار") and is_JoinChannel(msg) then
					ReplySet(msg,"unwarn")
				elseif CmdMatches and (CmdMatches:match('^setvip (.*)') or CmdMatches:match('^ویژه (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setvip (.*)') or CmdMatches:match('^ویژه (.*)')
					UseridSet(msg, Matches ,"setwhitelist")
				elseif CmdMatches and (CmdMatches:match('^remvip (.*)') or CmdMatches:match('^حذف ویژه (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^remvip (.*)') or CmdMatches:match('^حذف ویژه (.*)')
					UseridSet(msg, Matches ,"remwhitelist")
				elseif CmdMatches and (CmdMatches:match('^warn (.*)') or CmdMatches:match('^اخطار (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^warn (.*)') or CmdMatches:match('^اخطار (.*)')
					UseridSet(msg, Matches ,"warn")
				elseif CmdMatches and (CmdMatches:match('^unwarn (.*)') or CmdMatches:match('^حذف اخطار (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^unwarn (.*)') or CmdMatches:match('^حذف اخطار (.*)')
					UseridSet(msg, Matches ,"unwarn")
				elseif CmdMatches and (CmdMatches:match('^lock (.*)') or CmdMatches:match('^قفل (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(lock) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(قفل) (.*)$")
					}
					if CmdEn[2] == "link" or CmdFa[2] == "لینک" then
						Lock_Delmsg(msg, 'lock_link', "لینک")
					elseif CmdEn[2] == "tag" or CmdFa[2] == "تگ" then
						Lock_Delmsg(msg, "lock_tag", "تگ")
					elseif CmdEn[2] == "views" or CmdFa[2] == "ویو" then
						Lock_Delmsg(msg, "lock_views", "ویو")
					elseif CmdEn[2] == "username" or CmdFa[2] == "نام کاربری" then
						Lock_Delmsg(msg, "lock_username", "نام کاربری")
					elseif CmdEn[2] == "mention" or CmdFa[2] == "منشن" then
						Lock_Delmsg(msg, "lock_mention", "منشن")
					elseif CmdEn[2] == "farsi" or CmdFa[2] == "فارسی" then
						Lock_Delmsg(msg, "lock_arabic", "فارسی")
					elseif CmdEn[2] == "english" or CmdFa[2] == "انگلیسی" then
						Lock_Delmsg(msg, "lock_english", "انگلیسی")
					elseif CmdEn[2] == "edit" or CmdFa[2] == "ویرایش" then
						Lock_Delmsg(msg, "lock_edit", "ویرایش")
					elseif CmdEn[2] == "spam" or CmdFa[2] == "هرزنامه" then
						Lock_Delmsg(msg, "lock_spam", "هرزنامه")
					elseif CmdEn[2] == "flood" or CmdFa[2] == "پیام مکرر" then
						Lock_Delmsg(msg, "lock_flood", "پیام مکرر")
					elseif CmdEn[2] == "bots" or CmdFa[2] == "ربات" then
						Lock_Delmsg(msg, "lock_bots", "ربات")
					elseif CmdEn[2] == "bots pro" or CmdFa[2] == "ربات پیشرفته" then
						if redis:get(RedisIndex..'lock_bots:'..msg.chat_id) == 'Pro' then
							local rfa = Source_Start.."*قفل* `ربات` *از قبل فعال بود.*"..EndMsg.."\n*حالت قفل :* `حذف ربات و کاربر`"
							tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
						else
							local rfa = Source_Start.."*قفل* `ربات` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." *فعال شد.*"..EndMsg.."\n*حالت قفل :* `حذف ربات و کاربر`"
							tdbot.sendMessage(msg.chat_id , msg.id, 1, rfa, 0, 'md')
							redis:set(RedisIndex..'lock_bots:'..msg.chat_id, 'Pro')
						end
					elseif CmdEn[2] == "markdown" or CmdFa[2] == "فونت" then
						Lock_Delmsg(msg, "lock_markdown", "فونت")
					elseif CmdEn[2] == "webpage" or CmdFa[2] == "وب" then
						Lock_Delmsg(msg, "lock_webpage", "وب")
					elseif CmdEn[2] == "tabchi" or CmdFa[2] == "تبچی" then
						Lock_Delmsg(msg, "lock_tabchi", "تبچی")
					elseif (CmdEn[2] == "pin" or CmdFa[2] == "سنجاق") and is_owner(msg) then
						Lock_Delmsg(msg, "lock_pin", "سنجاق")
					elseif CmdEn[2] == "join" or CmdFa[2] == "ورود" then
						Lock_Delmsg(msg, "lock_join", "ورود")
					elseif CmdEn[2] == "all" or CmdFa[2] == "همه" then
						Lock_Delmsg(msg, "mute_all", "همه")
					elseif CmdEn[2] == "gif" or CmdFa[2] == "گیف" then
						Lock_Delmsg(msg, "mute_gif", "گیف")
					elseif CmdEn[2] == "text" or CmdFa[2] == "متن" then
						Lock_Delmsg(msg, "mute_text", "متن")
					elseif CmdEn[2] == "photo" or CmdFa[2] == "عکس" then
						Lock_Delmsg(msg, "mute_photo", "عکس")
					elseif CmdEn[2] == "video" or CmdFa[2] == "فیلم" then
						Lock_Delmsg(msg, "mute_video", "فیلم")
					elseif CmdEn[2] == "video_note" or CmdFa[2] == "فیلم سلفی" then
						Lock_Delmsg(msg, "mute_video_note", "فیلم سلفی")
					elseif CmdEn[2] == "audio" or CmdFa[2] == "اهنگ" then
						Lock_Delmsg(msg, "mute_audio", "آهنگ")
					elseif CmdEn[2] == "voice" or CmdFa[2] == "صدا" then
						Lock_Delmsg(msg, "mute_voice", "صدا")
					elseif CmdEn[2] == "sticker" or CmdFa[2] == "استیکر" then
						Lock_Delmsg(msg, "mute_sticker", "استیکر")
					elseif CmdEn[2] == "contact" or CmdFa[2] == "مخاطب" then
						Lock_Delmsg(msg, "mute_contact", "مخاطب")
					elseif CmdEn[2] == "forward" or CmdFa[2] == "فوروارد کانال" then
						Lock_Delmsg(msg, "mute_forward", "فوروارد کانال")
					elseif CmdEn[2] == "forward user" or CmdFa[2] == "فوروارد کاربر" then
						Lock_Delmsg(msg, "mute_forwarduser", "فوروارد کاربر")
					elseif CmdEn[2] == "location" or CmdFa[2] == "موقعیت" then
						Lock_Delmsg(msg, "mute_location", "موقعیت")
					elseif CmdEn[2] == "document" or CmdFa[2] == "فایل" then
						Lock_Delmsg(msg, "mute_document", "فایل")
					elseif CmdEn[2] == "tgservice" or CmdFa[2] == "سرویس تلگرام" then
						Lock_Delmsg(msg, "mute_tgservice", "سرویس تلگرام")
					elseif CmdEn[2] == "inline" or CmdFa[2] == "کیبورد شیشه ای" then
						Lock_Delmsg(msg, "mute_inline", "کیبورد شیشهای")
					elseif CmdEn[2] == "game" or CmdFa[2] == "بازی" then
						Lock_Delmsg(msg, "mute_game", "بازی")
					elseif CmdEn[2] == "keyboard" or CmdFa[2] == "صفحه کلید" then
						Lock_Delmsg(msg, "mute_keyboard", "صفحه کلید")
					elseif CmdEn[2] == "cmds" or CmdFa[2] == "دستورات" then
						tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`قفل دستورات` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." `فعال شد.`"..EndMsg, 1, 'md')
						redis:set(RedisIndex.."lock_cmd"..msg.chat_id,true)
					end
				elseif CmdMatches and (CmdMatches:match('^kick (.*)') or CmdMatches:match('^اخراج (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(kick) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(اخراج) (.*)$")
					}
					if CmdEn[2] == "link" or CmdFa[2] == "لینک" then
						Lock_Delmsg_kick(msg, 'lock_link', "لینک")
					elseif CmdEn[2] == "tag" or CmdFa[2] == "تگ" then
						Lock_Delmsg_kick(msg, "lock_tag", "تگ")
					elseif CmdEn[2] == "views" or CmdFa[2] == "ویو" then
						Lock_Delmsg_kick(msg, "lock_views", "ویو")
					elseif CmdEn[2] == "username" or CmdFa[2] == "نام کاربری" then
						Lock_Delmsg_kick(msg, "lock_username", "نام کاربری")
					elseif CmdEn[2] == "mention" or CmdFa[2] == "منشن" then
						Lock_Delmsg_kick(msg, "lock_mention", "منشن")
					elseif CmdEn[2] == "farsi" or CmdFa[2] == "فارسی" then
						Lock_Delmsg_kick(msg, "lock_arabic", "فارسی")
					elseif CmdEn[2] == "english" or CmdFa[2] == "انگلیسی" then
						Lock_Delmsg_kick(msg, "lock_english", "انگلیسی")
					elseif CmdEn[2] == "edit" or CmdFa[2] == "ویرایش" then
						Lock_Delmsg_kick(msg, "lock_edit", "ویرایش")
					elseif CmdEn[2] == "markdown" or CmdFa[2] == "فونت" then
						Lock_Delmsg_kick(msg, "lock_markdown", "فونت")
					elseif CmdEn[2] == "webpage" or CmdFa[2] == "وب" then
						Lock_Delmsg_kick(msg, "lock_webpage", "وب")
					elseif CmdEn[2] == "gif" or CmdFa[2] == "گیف" then
						Lock_Delmsg_kick(msg, "mute_gif", "گیف")
					elseif CmdEn[2] == "text" or CmdFa[2] == "متن" then
						Lock_Delmsg_kick(msg, "mute_text", "متن")
					elseif CmdEn[2] == "photo" or CmdFa[2] == "عکس" then
						Lock_Delmsg_kick(msg, "mute_photo", "عکس")
					elseif CmdEn[2] == "video" or CmdFa[2] == "فیلم" then
						Lock_Delmsg_kick(msg, "mute_video", "فیلم")
					elseif CmdEn[2] == "video_note" or CmdFa[2] == "فیلم سلفی" then
						Lock_Delmsg_kick(msg, "mute_video_note", "فیلم سلفی")
					elseif CmdEn[2] == "audio" or CmdFa[2] == "اهنگ" then
						Lock_Delmsg_kick(msg, "mute_audio", "آهنگ")
					elseif CmdEn[2] == "voice" or CmdFa[2] == "صدا" then
						Lock_Delmsg_kick(msg, "mute_voice", "صدا")
					elseif CmdEn[2] == "sticker" or CmdFa[2] == "استیکر" then
						Lock_Delmsg_kick(msg, "mute_sticker", "استیکر")
					elseif CmdEn[2] == "contact" or CmdFa[2] == "مخاطب" then
						Lock_Delmsg_kick(msg, "mute_contact", "مخاطب")
					elseif CmdEn[2] == "forward" or CmdFa[2] == "فوروارد کانال" then
						Lock_Delmsg_kick(msg, "mute_forward", "فوروارد کانال")
					elseif CmdEn[2] == "forward user" or CmdFa[2] == "فوروارد کاربر" then
						Lock_Delmsg_kick(msg, "mute_forwarduser", "فوروارد کاربر")
					elseif CmdEn[2] == "location" or CmdFa[2] == "موقعیت" then
						Lock_Delmsg_kick(msg, "mute_location", "موقعیت")
					elseif CmdEn[2] == "document" or CmdFa[2] == "فایل" then
						Lock_Delmsg_kick(msg, "mute_document", "فایل")
					elseif CmdEn[2] == "inline" or CmdFa[2] == "کیبورد شیشه ای" then
						Lock_Delmsg_kick(msg, "mute_inline", "کیبورد شیشه ای")
					elseif CmdEn[2] == "game" or CmdFa[2] == "بازی" then
						Lock_Delmsg_kick(msg, "mute_game", "بازی")
					elseif CmdEn[2] == "keyboard" or CmdFa[2] == "صفحه کلید" then
						Lock_Delmsg_kick(msg, "mute_keyboard", "صفحه کلید")
					end
				elseif CmdMatches and (CmdMatches:match('^mute (.*)') or CmdMatches:match('^سکوت (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(mute) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(سکوت) (.*)$")
					}
					if CmdEn[2] == "link" or CmdFa[2] == "لینک" then
						Lock_Delmsg_mute(msg, 'lock_link', "لینک")
					elseif CmdEn[2] == "tag" or CmdFa[2] == "تگ" then
						Lock_Delmsg_mute(msg, "lock_tag", "تگ")
					elseif CmdEn[2] == "views" or CmdFa[2] == "ویو" then
						Lock_Delmsg_mute(msg, "lock_views", "ویو")
					elseif CmdEn[2] == "username" or CmdFa[2] == "نام کاربری" then
						Lock_Delmsg_mute(msg, "lock_username", "نام کاربری")
					elseif CmdEn[2] == "mention" or CmdFa[2] == "منشن" then
						Lock_Delmsg_mute(msg, "lock_mention", "منشن")
					elseif CmdEn[2] == "farsi" or CmdFa[2] == "فارسی" then
						Lock_Delmsg_mute(msg, "lock_arabic", "فارسی")
					elseif CmdEn[2] == "english" or CmdFa[2] == "انگلیسی" then
						Lock_Delmsg_mute(msg, "lock_english", "انگلیسی")
					elseif CmdEn[2] == "edit" or CmdFa[2] == "ویرایش" then
						Lock_Delmsg_mute(msg, "lock_edit", "ویرایش")
					elseif CmdEn[2] == "markdown" or CmdFa[2] == "فونت" then
						Lock_Delmsg_mute(msg, "lock_markdown", "فونت")
					elseif CmdEn[2] == "webpage" or CmdFa[2] == "وب" then
						Lock_Delmsg_mute(msg, "lock_webpage", "وب")
					elseif CmdEn[2] == "gif" or CmdFa[2] == "گیف" then
						Lock_Delmsg_mute(msg, "mute_gif", "گیف")
					elseif CmdEn[2] == "text" or CmdFa[2] == "متن" then
						Lock_Delmsg_mute(msg, "mute_text", "متن")
					elseif CmdEn[2] == "photo" or CmdFa[2] == "عکس" then
						Lock_Delmsg_mute(msg, "mute_photo", "عکس")
					elseif CmdEn[2] == "video" or CmdFa[2] == "فیلم" then
						Lock_Delmsg_mute(msg, "mute_video", "فیلم")
					elseif CmdEn[2] == "video_note" or CmdFa[2] == "فیلم سلفی" then
						Lock_Delmsg_mute(msg, "mute_video_note", "فیلم سلفی")
					elseif CmdEn[2] == "audio" or CmdFa[2] == "اهنگ" then
						Lock_Delmsg_mute(msg, "mute_audio", "آهنگ")
					elseif CmdEn[2] == "voice" or CmdFa[2] == "صدا" then
						Lock_Delmsg_mute(msg, "mute_voice", "صدا")
					elseif CmdEn[2] == "sticker" or CmdFa[2] == "استیکر" then
						Lock_Delmsg_mute(msg, "mute_sticker", "استیکر")
					elseif CmdEn[2] == "contact" or CmdFa[2] == "مخاطب" then
						Lock_Delmsg_mute(msg, "mute_contact", "مخاطب")
					elseif CmdEn[2] == "forward" or CmdFa[2] == "فوروارد کانال" then
						Lock_Delmsg_mute(msg, "mute_forward", "فوروارد کانال")
					elseif CmdEn[2] == "forward user" or CmdFa[2] == "فوروارد کاربر" then
						Lock_Delmsg_mute(msg, "mute_forwarduser", "فوروارد کاربر")
					elseif CmdEn[2] == "location" or CmdFa[2] == "موقعیت" then
						Lock_Delmsg_mute(msg, "mute_location", "موقعیت")
					elseif CmdEn[2] == "document" or CmdFa[2] == "فایل" then
						Lock_Delmsg_mute(msg, "mute_document", "فایل")
					elseif CmdEn[2] == "inline" or CmdFa[2] == "کیبورد شیشه ای" then
						Lock_Delmsg_mute(msg, "mute_inline", "کیبورد شیشه ای")
					elseif CmdEn[2] == "game" or CmdFa[2] == "بازی" then
						Lock_Delmsg_mute(msg, "mute_game", "بازی")
					elseif CmdEn[2] == "keyboard" or CmdFa[2] == "صفحه کلید" then
						Lock_Delmsg_mute(msg, "mute_keyboard", "صفحه کلید")
					end
				elseif CmdMatches and (CmdMatches:match('^unlock (.*)') or CmdMatches:match('^بازکردن (.*)') or CmdMatches:match('^باز کردن (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(unlock) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(باز کردن) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(بازکردن) (.*)$")
					}
					if CmdEn[2] == 'auto' or CmdFa[2] == 'خودکار' then
						if redis:get(RedisIndex.."atolct1"..msg.to.id) and redis:get(RedisIndex.."atolct2"..msg.to.id) then
							redis:del(RedisIndex.."atolct1"..msg.to.id)
							redis:del(RedisIndex.."atolct2"..msg.to.id)
							redis:del(RedisIndex.."lc_ato:"..msg.to.id)
							tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`زمانبدی ربات برای قفل کردن خودکار گروه حذف شد`'..EndMsg, 1, 'md')
						else
							tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`قفل خودکار از قبل غیرفعال بود`'..EndMsg, 1, 'md')
						end
					elseif CmdEn[2] == "link" or CmdFa[2] == "لینک" then
						Unlock_Delmsg(msg, 'lock_link', "لینک")
					elseif CmdEn[2] == "tag" or CmdFa[2] == "تگ" then
						Unlock_Delmsg(msg, "lock_tag", "تگ")
					elseif CmdEn[2] == "views" or CmdFa[2] == "ویو" then
						Unlock_Delmsg(msg, "lock_views", "ویو")
					elseif CmdEn[2] == "username" or CmdFa[2] == "نام کاربری" then
						Unlock_Delmsg(msg, "lock_username", "نام کاربری")
					elseif CmdEn[2] == "mention" or CmdFa[2] == "منشن" then
						Unlock_Delmsg(msg, "lock_mention", "منشن")
					elseif CmdEn[2] == "farsi" or CmdFa[2] == "فارسی" then
						Unlock_Delmsg(msg, "lock_arabic", "فارسی")
					elseif CmdEn[2] == "english" or CmdFa[2] == "انگلیسی" then
						Unlock_Delmsg(msg, "lock_english", "انگلیسی")
					elseif CmdEn[2] == "edit" or CmdFa[2] == "ویرایش" then
						Unlock_Delmsg(msg, 'lock_edit', "ویرایش")
					elseif CmdEn[2] == "spam" or CmdFa[2] == "هرزنامه" then
						Unlock_Delmsg(msg, 'lock_spam', "هرزنامه")
					elseif CmdEn[2] == "flood" or CmdFa[2] == "پیام مکرر" then
						Unlock_Delmsg(msg, 'lock_flood', "پیام مکرر")
					elseif CmdEn[2] == "bots" or CmdFa[2] == "ربات" then
						Unlock_Delmsg(msg, 'lock_bots', "ربات")
					elseif CmdEn[2] == "markdown" or CmdFa[2] == "فونت" then
						Unlock_Delmsg(msg, "lock_markdown", "فونت")
					elseif CmdEn[2] == "webpage" or CmdFa[2] == "وب" then
						Unlock_Delmsg(msg, "lock_webpage", "وب")
					elseif CmdEn[2] == "tabchi" or CmdFa[2] == "تبچی" then
						Unlock_Delmsg(msg, "lock_tabchi", "تبچی")
					elseif (CmdEn[2] == "pin" or CmdFa[2] == "سنجاق") and is_owner(msg) then
						Unlock_Delmsg(msg, 'lock_pin', "سنجاق")
					elseif CmdEn[2] == "join" or CmdFa[2] == "ورود" then
						Unlock_Delmsg(msg, 'lock_join', "ورود")
					elseif CmdEn[2] == "all" or CmdFa[2] == "همه" then
						Unlock_Delmsg(msg, "mute_all", "همه")
					elseif CmdEn[2] == "gif" or CmdFa[2] == "گیف" then
						Unlock_Delmsg(msg, "mute_gif", "گیف")
					elseif CmdEn[2] == "text" or CmdFa[2] == "متن" then
						Unlock_Delmsg(msg, "mute_text", "متن")
					elseif CmdEn[2] == "photo" or CmdFa[2] == "عکس" then
						Unlock_Delmsg(msg, "mute_photo", "عکس")
					elseif CmdEn[2] == "video" or CmdFa[2] == "فیلم" then
						Unlock_Delmsg(msg, "mute_video", "فیلم")
					elseif CmdEn[2] == "video_note" or CmdFa[2] == "فیلم سلفی" then
						Unlock_Delmsg(msg, "mute_video_note", "فیلم سلفی")
					elseif CmdEn[2] == "audio" or CmdFa[2] == "اهنگ" then
						Unlock_Delmsg(msg, "mute_audio", "آهنگ")
					elseif CmdEn[2] == "voice" or CmdFa[2] == "صدا" then
						Unlock_Delmsg(msg, "mute_voice", "صدا")
					elseif CmdEn[2] == "sticker" or CmdFa[2] == "استیکر" then
						Unlock_Delmsg(msg, "mute_sticker", "استیکر")
					elseif CmdEn[2] == "contact" or CmdFa[2] == "مخاطب" then
						Unlock_Delmsg(msg, "mute_contact", "مخاطب")
					elseif CmdEn[2] == "forward" or CmdFa[2] == "فوروارد کانال" then
						Unlock_Delmsg(msg, "mute_forward", "فوروارد کانال")
					elseif CmdEn[2] == "forward user" or CmdFa[2] == "فوروارد کاربر" then
						Unlock_Delmsg(msg, "mute_forwarduser", "فوروارد کاربر")
					elseif CmdEn[2] == "location" or CmdFa[2] == "موقعیت" then
						Unlock_Delmsg(msg, "mute_location", "موقعیت")
					elseif CmdEn[2] == "document" or CmdFa[2] == "فایل" then
						Unlock_Delmsg(msg, "mute_document", "فایل")
					elseif CmdEn[2] == "tgservice" or CmdFa[2] == "سرویس تلگرام" then
						Unlock_Delmsg(msg, "mute_tgservice", "سرویس-تلگرام")
					elseif CmdEn[2] == "inline" or CmdFa[2] == "کیبورد شیشه ای" then
						Unlock_Delmsg(msg, "mute_inline", "کیبورد شیشه ای")
					elseif CmdEn[2] == "game" or CmdFa[2] == "بازی" then
						Unlock_Delmsg(msg, "mute_game", "بازی")
					elseif CmdEn[2] == "keyboard" or CmdFa[2] == "صفحه کلید" then
						Unlock_Delmsg(msg, "mute_keyboard", "صفحه کلید")
					elseif CmdEn[2] == "cmds" or CmdFa[2] == "دستورات" then
						tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`قفل دستورات` *توسط* `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." `غیرفعال شد.`"..EndMsg, 1, 'md')
						redis:del(RedisIndex.."lock_cmd"..msg.chat_id)
					end
				end
				if msg.to.type == "channel" then
					if (CmdMatches == "gpinfo" or CmdMatches == "اطلاعات گروه") and is_JoinChannel(msg) then
						local function group_info(arg, data)
							if data.description and data.description ~= "" then
								des = check_markdown(data.description)
							else
								des = ""
							end
							ginfo = Source_Start.."*اطلاعات گروه :*\n`تعداد مدیران :` *"..data.administrator_count.."*\n`تعداد اعضا :` *"..data.member_count.."*\n`تعداد اعضای حذف شده :` *"..data.banned_count.."*\n`تعداد اعضای محدود شده :` *"..data.restricted_count.."*\n`شناسه گروه :` *"..msg.to.id.."*\n`توضیحات گروه :` "..des
							tdbot.sendMessage(arg.chat_id, arg.msg_id, 1, ginfo, 1, 'md')
						end
						tdbot.getChannelFull(msg.to.id, group_info, {chat_id=msg.to.id,msg_id=msg.id})
					elseif CmdMatches and (CmdMatches:match('^setabout (.*)') or CmdMatches:match('^تنظیم درباره (.*)')) and is_JoinChannel(msg) then
						local Matches = CmdMatches:match('^setabout (.*)') or CmdMatches:match('^تنظیم درباره (.*)')
						tdbot.changeChannelDescription(chat, Matches, dl_cb, nil)
						redis:set(RedisIndex..msg.to.id..'about', Matches)
						text = Source_Start.."`پیام مبنی بر درباره گروه ثبت شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				end
				if CmdMatches and (CmdMatches:match('^setwelcome (.*)') or CmdMatches:match('^تنظیم خوشامد (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setwelcome (.*)') or CmdMatches:match('^تنظیم خوشامد (.*)')
					redis:set(RedisIndex..'setwelcome:'..msg.chat_id, Matches)
					text = Source_Start.."`پیام خوشآمد گویی تنظیم شد به :`\n*"..Matches.."*\n\n*شما میتوانید از*\n_{gpname} نام گروه_\n_{rules} ➣ نمایش قوانین گروه_\n_{time} ➣ ساعت به زبان انگلیسی _\n_{date} ➣ تاریخ به زبان انگلیسی _\n_{timefa} ➣ ساعت به زبان فارسی _\n_{datefa} ➣ تاریخ به زبان فارسی _\n_{name} ➣ نام کاربر جدید_\n_{username} ➣ نام کاربری کاربر جدید_\n`استفاده کنید`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^setname (.*)') or CmdMatches:match('^تنظیم نام (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setname (.*)') or CmdMatches:match('^تنظیم نام (.*)')
					local gp_name = Matches
					tdbot.changeChatTitle(chat, gp_name, dl_cb, nil)
				elseif CmdMatches and (CmdMatches:match('^res (.*)') or CmdMatches:match('^کاربری (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^res (.*)') or CmdMatches:match('^کاربری (.*)')
					tdbot_function ({
					_ = "searchPublicChat",
					username = Matches
					}, action_by_username, {chat_id=msg.to.id,username=Matches,cmd="res"})
				elseif CmdMatches and (CmdMatches:match('^setrules (.*)') or CmdMatches:match('^تنظیم قوانین (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setrules (.*)') or CmdMatches:match('^تنظیم قوانین (.*)')
					redis:set(RedisIndex..msg.to.id..'rules', Matches)
					text = Source_Start.."`قوانین گروه ثبت شد`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^whois (%d+)') or CmdMatches:match('^شناسه (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^whois (%d+)') or CmdMatches:match('^شناسه (%d+)')
					tdbot_function ({
					_ = "getUser",
					user_id = Matches,
					}, action_by_id, {chat_id=msg.to.id,user_id=Matches,cmd="whois"})
				elseif (CmdMatches == "warnlist" or CmdMatches == "لیست اخطار") and is_JoinChannel(msg) then
					local list = Source_Start..'لیست اخطار :\n'
					local empty = list
					for k,v in pairs (redis:hkeys(RedisIndex..msg.to.id..':warn')) do
						local user_name = redis:get(RedisIndex..'user_name:'..v) or "---"
						local cont = redis:hget(RedisIndex..msg.to.id..':warn', v)
						if user_name then
							list = list..k..'- '..check_markdown(user_name)..' [`'..v..'`] \n*اخطار : '..(cont - 1)..'*\n'
						else
							list = list..k..'- `'..v..'` \n*اخطار : '..(cont - 1)..'*\n'
						end
					end
					if list == empty then
						text = Source_Start..'*لیست اخطار خالی است*'..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					else
						return list
					end
				elseif (CmdMatches == 'setdow' or CmdMatches == 'تنظیم دانلود') and is_JoinChannel(msg) then
					if redis:get(RedisIndex..'Num1Time:'..msg.to.id) and not is_admin(msg) then
						tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."`اجرای این دستور هر 1 ساعت یک بار ممکن است.`"..EndMsg, 1, 'md')
					else
						redis:setex(RedisIndex..'Num1Time:'..msg.to.id, 3600, true)
						redis:setex(RedisIndex..'AutoDownload:'..msg.to.id, 1200, true)
						local text = Source_Start..'*با موفقیت ثبت شد.*\n`مدیران و مالک گروه  میتواند به مدت 20 دقیقه از دستوراتی که نیاز به دانلود دارند استفاده کنند`\n*'..Source_Start..' نکته :* اجرای این دستور هر 1 ساعت یک بار ممکن است.'..EndMsg
						tdbot.sendMessage(msg.chat_id, msg.id, 1, text, 1, 'md')
					end
				elseif (CmdMatches == "del" or CmdMatches == "حذف") and is_JoinChannel(msg) and msg.reply_id then
					del_msg(msg.to.id, msg.reply_id)
					del_msg(msg.to.id, msg.id)
				elseif CmdMatches and (CmdMatches:match('^welcome (.*)') or CmdMatches:match('^خوشامد (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(welcome) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(خوشامد ) (.*)$")
					}
					if CmdEn[2] == "enable" or CmdFa[2] == "فعال"  then
						welcome = redis:get(RedisIndex..'welcome:'..msg.chat_id)
						if welcome == 'Enable' then
							text = Source_Start.."`خوشآمد گویی از قبل فعال بود`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						else
							redis:set(RedisIndex..'welcome:'..msg.chat_id, 'Enable')
							text = Source_Start.."`خوشآمد گویی فعال شد`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						end
					end
					if CmdEn[2] == "disable" or CmdFa[2] == "غیرفعال" then
						welcome = redis:get(RedisIndex..'welcome:'..msg.chat_id)
						if welcome == 'Enable' then
							redis:del(RedisIndex..'welcome:'..msg.chat_id)
							text = Source_Start.."`خوشآمد گویی غیرفعال شد`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						else
							text = Source_Start.."`خوشآمد گویی از قبل فعال نبود`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						end
					end
				elseif (CmdMatches == "pin" or CmdMatches == "سنجاق") and msg.reply_id and is_JoinChannel(msg) then
					local lock_pin = redis:get(RedisIndex..'lock_pin:'..msg.chat_id)
					if lock_pin == 'Enable' then
						if is_owner(msg) then
							tdbot.pinChannelMessage(msg.to.id, msg.reply_id, 1, dl_cb, nil)
							text = Source_Start.."`پیام سجاق شد`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						elseif not is_owner(msg) then
							return
						end
					elseif not lock_pin then
						redis:set(RedisIndex..'pin_msg'..msg.chat_id, msg.reply_id)
						tdbot.pinChannelMessage(msg.to.id, msg.reply_id, 1, dl_cb, nil)
						text = Source_Start.."`پیام سجاق شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif (CmdMatches == 'unpin' or CmdMatches == "حذف سنجاق") and is_JoinChannel(msg) then
					local lock_pin = redis:get(RedisIndex..'lock_pin:'..msg.chat_id)
					if lock_pin == 'Enable' then
						if is_owner(msg) then
							tdbot.unpinChannelMessage(msg.to.id, dl_cb, nil)
							text = Source_Start.."`پیام سنجاق شده پاک شد`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						elseif not is_owner(msg) then
							return
						end
					elseif not lock_pin then
						tdbot.unpinChannelMessage(msg.to.id, dl_cb, nil)
						text = Source_Start.."`پیام سنجاق شده پاک شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^lockgp (%d+) (%d+) (%d+)') or CmdMatches:match('^قفل گروه (%d+) (%d+) (%d+)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(lockgp) (%d+) (%d+) (%d+)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(قفل گروه) (%d+) (%d+) (%d+)$")
					}
					local Matches1 = CmdEn[2] or CmdFa[2]
					local Matches2 = CmdEn[3] or CmdFa[3]
					local Matches3 = CmdEn[4] or CmdFa[4]
					local hour = string.gsub(Matches1, "h", "")
					local num1 = tonumber(hour) * 3600
					local minutes = string.gsub(Matches2, "m", "")
					local num2 = tonumber(minutes) * 60
					local second = string.gsub(Matches3, "s", "")
					local num3 = tonumber(second)
					local timelock = tonumber(num1 + num2 + num3)
					redis:setex(RedisIndex..'Lock_Gp:'..msg.to.id, timelock, true)
					tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`گروه به مدت` *"..Matches1.."* `ساعت` *"..Matches2.."* `دقیقه` *"..Matches3.."* `ثانیه توسط` `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." `قفل شد`"..EndMsg, 1, 'md')
				elseif CmdMatches and (CmdMatches:match('^lockgp (%d+)[mhs]') or CmdMatches:match('^قفل گروه (%d+)[mhs]')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^lockgp (.*)') or CmdMatches:match('^قفل گروه (.*)')
					if Matches:match('(%d+)h') then
						time_match = Matches:match('(%d+)h')
						time = time_match * 3600
					end
					if Matches:match('(%d+)s') then
						time_match = Matches:match('(%d+)s')
						time = time_match
					end
					if Matches:match('(%d+)m') then
						time_match = Matches:match('(%d+)m')
						time = time_match * 60
					end
					local timelock = tonumber(time)
					redis:setex(RedisIndex..'Lock_Gp:'..msg.to.id, timelock, true)
					tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."`گروه به مدت` *"..time.."* `ثانیه توسط` `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." `قفل شد`"..EndMsg, 1, 'md')
				elseif (CmdMatches == 'newlink' or CmdMatches == "لینک جدید") and is_JoinChannel(msg) then
					local function callback_link (arg, data)
						if not data.invite_link then
							return tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`ربات ادمین گروه نیست`\n`با دستور` *setlink/* `لینک جدیدی برای گروه ثبت کنید"..EndMsg, 1, 'md')
						else
							redis:set(RedisIndex..msg.to.id..'linkgpset', data.invite_link)
							return tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start.."`لینک جدید ساخته شد`"..EndMsg, 1, 'md')
						end
					end
					tdbot.exportChatInviteLink(msg.to.id, callback_link, nil)
				elseif (CmdMatches == 'link' or CmdMatches == "لینک") and is_JoinChannel(msg) then
					local linkgp = redis:get(RedisIndex..msg.to.id..'linkgpset')
					if not linkgp then
						text = Source_Start.."`ابتدا با دستور` *newlink/* `لینک جدیدی برای گروه بسازید`\n`و اگر ربات سازنده گروه نیس با دستور` *setlink/* `لینک جدیدی برای گروه ثبت کنید`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					text = Source_Start.."<b>لینک گروه :</b>\n"..linkgp
					return tdbot.sendMessage(msg.chat_id, msg.id, 1, text, 1, 'html')
				elseif (CmdMatches == 'linkpv' or CmdMatches == "لینک خصوصی") and is_JoinChannel(msg) then
					if redis:get(RedisIndex..msg.from.id..'chkusermonshi') and not is_admin(msg) then
						tdbot.sendMessage(msg.chat_id, msg.id, 1, "`لطفا پیوی ربات پیام ازسال کنید سپس دستور را وارد نماید.`"..EndMsg, 1, 'md')
					else
						local linkgp = redis:get(RedisIndex..msg.to.id..'linkgpset')
						if not linkgp then
							text = Source_Start.."`ابتدا با دستور` *newlink/* `لینک جدیدی برای گروه بسازید`\n`و اگر ربات سازنده گروه نیس با دستور` *setlink/* `لینک جدیدی برای گروه ثبت کنید`"..EndMsg
							tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						end
						tdbot.sendMessage(msg.sender_user_id, "", 1, "<b>لینک گروه </b> : <code>"..msg.to.title.."</code> :\n"..linkgp, 1, 'html')
						text = Source_Start.."`لینک گروه به چت خصوصی شما ارسال شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^setchar (%d+)') or CmdMatches:match('^حداکثر حروف مجاز (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setchar (%d+)') or CmdMatches:match('^حداکثر حروف مجاز (%d+)')
					redis:set(RedisIndex..msg.to.id..'set_char', Matches)
					text = Source_Start.."`حداکثر حروف مجاز در پیام تنظیم شد به :` *[ "..Matches.." ]*"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^setflood (%d+)') or CmdMatches:match('^تنظیم پیام مکرر (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setflood (%d+)') or CmdMatches:match('^تنظیم پیام مکرر (%d+)')
					if tonumber(Matches) < 1 or tonumber(Matches) > 50 then
						text = Source_Start.."`باید بین` *[2-50]* `تنظیم شود`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					local flood_max = Matches
					redis:set(RedisIndex..msg.to.id..'num_msg_max', flood_max)
					text = Source_Start..'`محدودیت پیام مکرر به` *'..tonumber(Matches)..'* `تنظیم شد.`'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^setfloodtime (%d+)') or CmdMatches:match('^تنظیم زمان بررسی (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setfloodtime (%d+)') or CmdMatches:match('^تنظیم زمان بررسی (%d+)')
					if tonumber(Matches) < 2 or tonumber(Matches) > 10 then
						text = Source_Start.."`باید بین` *[2-10]* `تنظیم شود`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					local time_max = Matches
					redis:set(RedisIndex..msg.to.id..'time_check', time_max)
					text = Source_Start.."`حداکثر زمان بررسی پیام های مکرر تنظیم شد به :` *[ "..Matches.." ]*"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches == "about" or CmdMatches == "درباره" then
					if not redis:get(RedisIndex..msg.to.id..'about') then
						text =  Source_Start.."`پیامی مبنی بر درباره گروه ثبت نشده است`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					else
						text = Source_Start.."*درباره گروه :*\n"..redis:get(RedisIndex..msg.to.id..'about')
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^setwarn (%d+)') or CmdMatches:match('^حداکثر اخطار (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^setwarn (%d+)') or CmdMatches:match('^حداکثر اخطار (%d+)')
					if tonumber(Matches) < 1 or tonumber(Matches) > 20 then
						text = Source_Start.."`لطفا عددی بین [1-20] را انتخاب کنید`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
					local warn_max = Matches
					redis:set(RedisIndex..'max_warn:'..msg.to.id, warn_max)
					text = Source_Start.."`حداکثر اخطار تنظیم شد به :` *[ "..Matches.." ]*"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				elseif CmdMatches and (CmdMatches:match('^rmsg (%d+)') or CmdMatches:match('^پاکسازی (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^rmsg (%d+)') or CmdMatches:match('^پاکسازی (%d+)')
					if tonumber(Matches) > 1000 then
						tdbot.sendMessage(msg.chat_id,  msg.id, 0, Source_Start.."*عددی بین * [`1-1000`] را انتخاب کنید"..EndMsg, 0, "md")
					else
						local function cb(arg,data)
							for k,v in pairs(data.messages) do
								del_msg(msg.chat_id, v.id)
							end
						end
						tdbot.getChatHistory(msg.to.id, msg.id, 0,  Matches, 0, cb, nil)
						tdbot.sendMessage(msg.chat_id,  msg.id, 0, Source_Start.."`تعداد` *("..Matches..")* `پیام پاکسازی شد`"..EndMsg, 0, "md")
					end
				elseif (CmdMatches == "panel" or CmdMatches == "پنل") and is_JoinChannel(msg) then
					local function inline_query_cb(arg, data)
						if data.results and data.results[0] then
							redis:setex(RedisIndex.."ReqMenu:" .. msg.to.id .. ":" .. msg.from.id, 260, true) redis:setex(RedisIndex.."ReqMenu:" .. msg.to.id, 10, true) tdbot.sendInlineQueryResultMessage(msg.to.id, msg.id, 0, 1, data.inline_query_id, data.results[0].id, dl_cb, nil)
						else
							text = Source_Start.."مشکل فنی در ربات هلپر"..EndMsg
							return tdbot.sendMessage(msg.to.id, msg.id, 0, text, 0, "md")
						end
					end
					tdbot.getInlineQueryResults(Bot_idapi, msg.to.id, 0, 0, "Menu:"..msg.to.id, 0, inline_query_cb, nil)
				elseif (CmdMatches == "help" or CmdMatches == "راهنما") and is_JoinChannel(msg) then
					local function inline_query_cb(arg, data)
						if data.results and data.results[0] then
							redis:setex(RedisIndex.."ReqMenu:" .. msg.to.id .. ":" .. msg.from.id, 260, true) redis:setex(RedisIndex.."ReqMenu:" .. msg.to.id, 10, true) tdbot.sendInlineQueryResultMessage(msg.to.id, msg.id, 0, 1, data.inline_query_id, data.results[0].id, dl_cb, nil)
						else
							text = Source_Start.."مشکل فنی در ربات هلپر"..EndMsg
							return tdbot.sendMessage(msg.to.id, msg.id, 0, text, 0, "md")
						end
					end
					tdbot.getInlineQueryResults(Bot_idapi, msg.to.id, 0, 0, "Help:"..msg.to.id, 0, inline_query_cb, nil)	
				elseif (CmdMatches == "panelpv" or CmdMatches == "پنل خصوصی") and is_JoinChannel(msg) then
					if not redis:get(RedisIndex..msg.from.id..'chkusermonshi') and not is_admin(msg) then
						tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."`شما برای اجرای این دستور ابتدا باید خصوصی ربات پیام دهید.`"..EndMsg, 1, 'md')
					else
						local function inline_query_cb(arg, data)
							if data.results and data.results[0] then
								redis:setex(RedisIndex.."ReqMenu:" .. msg.to.id .. ":" .. msg.from.id, 260, true) redis:setex(RedisIndex.."ReqMenu:" .. msg.to.id, 10, true) tdbot.sendInlineQueryResultMessage(msg.from.id, msg.id, 0, 1, data.inline_query_id, data.results[0].id, dl_cb, nil)
							else
								text = Source_Start.."مشکل فنی در ربات هلپر"..EndMsg
								return tdbot.sendMessage(msg.to.id, msg.id, 0, text, 0, "md")
							end
						end
						tdbot.getInlineQueryResults(Bot_idapi, msg.from.id, 0, 0, "Menu:"..msg.to.id, 0, inline_query_cb, nil)
						tdbot.sendMessage(msg.to.id, msg.id, 0, Source_Start.."`پنل به خصوصی شما ارسال شد.`"..EndMsg, 0, "md")
					end
				elseif CmdMatches and (CmdMatches:match('^delbot (.*)') or CmdMatches:match('^پاکسازی ربات (.*)')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(delbot) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(پاکسازی ربات) (.*)$")
					}
					if CmdEn[2] == "on" or CmdFa[2] == "فعال" then
						redis:set(RedisIndex.."delbot"..msg.to.id, true)
						redis:set(RedisIndex.."deltimebot"..msg.chat_id , 60)
						text = Source_Start.."`پاکسازی خودکار پیام های ربات توسط` `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." `فعال شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					elseif CmdEn[2] == "off" or CmdFa[2] == "غیرفعال" then
						redis:del(RedisIndex.."delbot"..msg.to.id)
						redis:del(RedisIndex.."deltimebot"..msg.chat_id)
						text = Source_Start.."`پاکسازی خودکار پیام های ربات توسط` `"..msg.from.id.."` - @"..check_markdown(msg.from.username or '').." `غیرفعال شد`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^deltimebot (%d+)') or CmdMatches:match('^زمان پاکسازی ربات (%d+)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^deltimebot (%d+)') or CmdMatches:match('^زمان پاکسازی ربات (%d+)')
					if tonumber(Matches) < 10 or tonumber(Matches) > 300 then
						text = Source_Start.."`باید بین` *[10 - 300]* `تنظیم شود`"..EndMsg
						tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
						else
					redis:set(RedisIndex.."deltimebot"..msg.chat_id , Matches)
					text = Source_Start.."`زمان پاکسازی پیام ربات تنظیم شد به هر` *[ "..Matches.." ]* `ثانیه`"..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
					end
				elseif CmdMatches and (CmdMatches:match('^(lock auto) (%d+):(%d+)-(%d+):(%d+)$') or CmdMatches:match('^(قفل خودکار) (%d+):(%d+)-(%d+):(%d+)$')) and is_JoinChannel(msg) then
					local CmdEn = {
					string.match(CmdMatches, "^(lock auto) (%d+):(%d+)-(%d+):(%d+)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(قفل خودکار) (%d+):(%d+)-(%d+):(%d+)$")
					}
					local Matches2 = CmdEn[2] or CmdFa[2]
					local Matches3 = CmdEn[3] or CmdFa[3]
					local Matches4 = CmdEn[4] or CmdFa[4]
					local Matches5 = CmdEn[5] or CmdFa[5]
					local End = Matches4..":"..Matches5
					local Start = Matches2..":"..Matches3
					if End == Start then
						tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`آغاز قفل خودکار نمیتوانید با پایان آن یکی باشد`'..EndMsg, 1, 'md')
					else
						tdbot.sendMessage(msg.to.id, msg.id, 1, Source_Start..'`عملیات با موقیت انجام شد.\n\nگروه شما در ساعت` *'..Start..'* `الی` *'..End..'* `بصورت خودکار تعطیل خواهد شد.`'..EndMsg, 1, 'md')
						redis:set(RedisIndex.."atolct1"..msg.to.id,Start)
						redis:set(RedisIndex.."atolct2"..msg.to.id,End)
					end
				elseif CmdMatches and (CmdMatches:match('^mute (%d+) (.*)') or CmdMatches:match('^سکوت (%d+) (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^mute (%d+)') or CmdMatches:match('^سکوت (%d+)')
					local CmdEn = {
					string.match(CmdMatches, "^(mute) (%d+) (.*)$")
					}
					local CmdFa = {
					string.match(CmdMatches, "^(سکوت) (%d+) (.*)$")
					}
					local time = Matches
					if CmdEn[3] == "d" or CmdFa[3] == "روز" then
						local hour = tonumber(time) * 86400
						local timemute = tonumber(hour)
						local function Restricted(arg, data)
							if data.sender_user_id == our_id then
								return tdbot.sendMessage(msg.chat_id, "", 0, Source_Start.."*من نمیتوانم توانایی چت کردن رو از خودم بگیرم*"..EndMsg, 0, "md")
							end
							if is_mod1(msg.chat_id, data.sender_user_id) then
								return tdbot.sendMessage(msg.chat_id, "", 0, Source_Start.."*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه، و ادمین های ربات بگیرید*"..EndMsg, 0, "md")
							end
							tdbot.Restricted(msg.chat_id,data.sender_user_id,'Restricted',   {1,msg.date+timemute, 0, 0, 0,0})
							tdbot.sendMention(msg.chat_id,data.sender_user_id, data.id,Source_Start.."کاربر [ "..data.sender_user_id.." ]  به مدت "..time.." ساعت سکوت شد"..EndMsg,10,string.len(data.sender_user_id))
						end
						tdbot.getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Restricted, nil)
					elseif CmdEn[3] == "h" or CmdFa[3] == "ساعت" then
						local hour = tonumber(time) * 3600
						local timemute = tonumber(hour)
						local function Restricted(arg, data)
							if data.sender_user_id == our_id then
								return tdbot.sendMessage(msg.chat_id, "", 0, Source_Start.."*من نمیتوانم توانایی چت کردن رو از خودم بگیرم*"..EndMsg, 0, "md")
							end
							if is_mod1(msg.chat_id, data.sender_user_id) then
								return tdbot.sendMessage(msg.chat_id, "", 0, Source_Start.."*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه، و ادمین های ربات بگیرید*"..EndMsg, 0, "md")
							end
							tdbot.Restricted(msg.chat_id,data.sender_user_id,'Restricted',   {1,msg.date+timemute, 0, 0, 0,0})
							tdbot.sendMention(msg.chat_id,data.sender_user_id, data.id,Source_Start.."کاربر [ "..data.sender_user_id.." ]  به مدت "..time.." ساعت سکوت شد"..EndMsg,10,string.len(data.sender_user_id))
						end
						tdbot.getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Restricted, nil)
					elseif CmdEn[3] == "m" or CmdFa[3] == "دقیقه" then
						local minutes = tonumber(time) * 60
						local timemute = tonumber(minutes)
						local function Restricted(arg,data)
							if data.sender_user_id == our_id then
								return tdbot.sendMessage(msg.chat_id, "", 0, Source_Start.."*من نمیتوانم توانایی چت کردن رو از خودم بگیرم*"..EndMsg, 0, "md")
							end
							if is_mod1(msg.chat_id, data.sender_user_id) then
								return tdbot.sendMessage(msg.chat_id, "", 0, Source_Start.."*شما نمیتوانید توانایی چت کردن رو از مدیران،صاحبان گروه، و ادمین های ربات بگیرید*"..EndMsg, 0, "md")
							end
							tdbot.Restricted(msg.chat_id,data.sender_user_id,'Restricted',   {1,msg.date+timemute, 0, 0, 0,0})
							tdbot.sendMention(msg.chat_id,data.sender_user_id, data.id,Source_Start.."کاربر [ "..data.sender_user_id.." ]  به مدت "..time.." دقیقه سکوت شد"..EndMsg,10,string.len(data.sender_user_id))
						end
						tdbot.getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Restricted, nil)
					end
				elseif (CmdMatches == 'filterlist' or CmdMatches == "لیست فیلتر") and is_JoinChannel(msg) then
					return filter_list(msg)
				elseif (CmdMatches == "settings" or CmdMatches == "تنظیمات") and is_JoinChannel(msg) then
					return group_settings(msg)
				elseif (CmdMatches == 'modlist' or CmdMatches == "لیست مدیران") and is_JoinChannel(msg) then
					return modlist(msg)
				elseif (CmdMatches == "viplist" or CmdMatches == "لیست ویژه") and is_JoinChannel(msg) then
					return whitelist(msg)
				elseif CmdMatches and (CmdMatches:match('^filter (.*)') or CmdMatches:match('^فیلتر (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^filter (.*)') or CmdMatches:match('^فیلتر (.*)')
					return filter_word(msg, Matches)
				elseif CmdMatches and (CmdMatches:match('^unfilter (.*)') or CmdMatches:match('^حذف فیلتر (.*)')) and is_JoinChannel(msg) then
					local Matches = CmdMatches:match('^unfilter (.*)') or CmdMatches:match('^حذف فیلتر (.*)')
					return unfilter_word(msg, Matches)
				end
			end
			if redis:get(RedisIndex.."lock_cmd"..msg.chat_id) and not is_mod(msg) then return false end
			if (CmdMatches == "id"  or CmdMatches == "ایدی" or CmdMatches == "آیدی") and tonumber(msg.reply_to_message_id) == 0 then
				if redis:get(RedisIndex.."lock_cmd"..msg.chat_id) and not is_mod(msg) then return else
					local function getpro(arg, data)
						local user_info_msgs = tonumber(redis:get(RedisIndex..'msgs:'..msg.sender_user_id..':'..msg.chat_id) or 0)
						local gap_info_msgs = tonumber(redis:get(RedisIndex..'msgs:'..msg.chat_id) or 0)
						if not data.photos[0] then
							tdbot.sendMessage(msg.chat_id, msg.id, 1, ''..Source_Start..'شناسه گروه : '..msg.chat_id..'\n'..Source_Start..'تعداد پیام های گروه : [ '..gap_info_msgs..' ]\n'..Source_Start..'شناسه شما : '..msg.sender_user_id..'\n'..Source_Start..'تعداد پیام های شما : [ '..user_info_msgs..' ]\n'..Source_Start..' نام کاربری : @'..msg.from.username or msg.from.first_name..'', 1, 'md')
						else
							tdbot.sendPhoto(msg.chat_id, msg.id, data.photos[0].sizes[1].photo.persistent_id, 0, {}, 0, 0, ''..Source_Start..'شناسه گروه : '..msg.chat_id..'\n'..Source_Start..'تعداد پیام های گروه : [ '..gap_info_msgs..' ]\n'..Source_Start..'شناسه شما : '..msg.sender_user_id..'\n'..Source_Start..'تعداد پیام های شما : [ '..user_info_msgs..' ]\n'..Source_Start..' نام کاربری : @'..msg.from.username or msg.from.first_name..'', 0, 0, 1, nil, dl_cb, nil)
						end
					end
					assert(tdbot_function ({
					_ = "getUserProfilePhotos",
					user_id = msg.sender_user_id,
					offset = 0,
					limit = 1
					}, getpro, nil))
				end
			elseif (CmdMatches == "id" or CmdMatches == "ایدی" or CmdMatches == "آیدی") and tonumber(msg.reply_to_message_id) ~= 0 and is_mod(msg) then
				if redis:get(RedisIndex.."lock_cmd"..msg.chat_id) and not is_mod(msg) then return else
					assert(tdbot_function ({
					_ = "getMessage",
					chat_id = msg.chat_id,
					message_id = msg.reply_to_message_id
					}, action_by_reply1, {chat_id=msg.chat_id,cmd="id"}))
				end
			elseif (CmdMatches == "ping" ) or (CmdMatches == "انلاینی" ) or (CmdMatches == "آنلاینی" ) then
				tdbot.sendMention(msg.chat_id,msg.sender_user_id, msg.id,Source_Start..'ربات بروز و آماده به دستور است.'..EndMsg,7, tonumber(Slen("بروز")))
			elseif CmdMatches == "bot" or CmdMatches == "ربات" then
				local bot = {"جانم","بگو عزیز دلم","بفرماید","جانم دلم"}
				local b = bot[math.random(#bot)]
				local laghab = redis:get(RedisIndex..'laghab:'..tostring(msg.from.id))
				if laghab then
					text = b.." "..laghab..""
				else
					text = b
				end
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches == 'nerkh' or CmdMatches == 'نرخ' then
				local hash = ('nerkh')
				local nerkh = redis:get(RedisIndex..hash)
				if not nerkh then
					tdbot.sendMessage(msg.chat_id , msg.id, 1, Source_Start..'`نرخی برای ربات ثبت نشده است`'..EndMsg, 0, 'md')
				else
					tdbot.sendMessage(msg.chat_id, msg.id, 1, check_markdown(nerkh), 1, 'md')
				end
			elseif CmdMatches == 'شماره کارت' then
				local hash = ('cart')
				local cart = redis:get(RedisIndex..hash)
				if not cart then
					text = Source_Start..'`شماره کارتی برای ربات ثبت نشده است`'..EndMsg
					tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
				else
					tdbot.sendMessage(msg.chat_id, msg.id, 1, check_markdown(cart), 1, 'md')
				end
			elseif CmdMatches == 'mydel' or CmdMatches == 'پاکسازی پیام های من' then
				tdbot.deleteMessagesFromUser(msg.to.id,  msg.sender_user_id, dl_cb, nil)
				text = Source_Start.."*پیام های کاربر :*\n[@"..check_markdown(msg.from.username or '').."*|*`"..msg.from.id.."`]\n *پاکسازی شد توسط خودش*"..EndMsg
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches == "rules" or CmdMatches == "قوانین" then
				if not redis:get(RedisIndex..msg.to.id..'rules') then
					rules = Source_Start.."`قوانین ثبت نشده است`"..EndMsg
				else
					rules = Source_Start.."*قوانین گروه :*\n"..redis:get(RedisIndex..msg.to.id..'rules')
				end
				text = rules
				tdbot.sendMessage(msg.chat_id , msg.id, 1, text, 0, 'md')
			elseif CmdMatches and (CmdMatches:match('^id (.*)') or CmdMatches:match('^ایدی (.*)') or CmdMatches:match('^آیدی (.*)')) then
				local Matches = CmdMatches:match('^id (.*)') or CmdMatches:match('^ایدی (.*)') or CmdMatches:match('^آیدی (.*)')
				if Matches and is_mod(msg) then
					if msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" then
						local function idmen(arg, data)
							if data.id then
								local user_name = "پیدا نشد"
								if data.username and data.username ~= "" then user_name = '@'..check_markdown(data.username) end
								local print_name = data.first_name
								if data.last_name and data.last_name ~= "" then print_name = print_name..' '..data.last_name end
								text = Source_Start.."*نام :* "..check_markdown(print_name).."\n"..Source_Start.."*ایدی :* `"..data.id.."`"
								return tdbot.sendMessage(msg.to.id, "", 0, text, 0, "md")
							end
						end
						tdbot.getUser(msg.content.entities[0].type.user_id, idmen)
					end
				end
			elseif CmdMatches == "info" or CmdMatches == "اطلاعات" then
				if tonumber(msg.reply_to_message_id) ~= 0 then
					assert (tdbot_function ({
					_ = "getMessage",
					chat_id = msg.chat_id,
					message_id = msg.reply_to_message_id
					}, info_by_reply, {chat_id=msg.chat_id}))
				end
				if tonumber(msg.reply_to_message_id) == 0 then
					local function info2_cb(arg, data)
						if tonumber(data.id) then
							if data.username then
								username = "@"..check_markdown(data.username)
							else
								username = ""
							end
							if data.first_name then
								firstname = check_markdown(data.first_name)
							else
								firstname = ""
							end
							if data.last_name then
								lastname = check_markdown(data.last_name)
							else
								lastname = ""
							end
							local text = Source_Start.."*نام :* `"..firstname.."`\n"..Source_Start.."*فامیلی :* `"..lastname.."`\n"..Source_Start.."*نام کاربری :* "..username.."\n"..Source_Start.."*آیدی :* `"..data.id.."`\n"
							if is_leader1(data.id) then
								text = text..Source_Start..'*مقام :* `سازنده سورس`\n'
							elseif is_sudo1(data.id) then
								text = text..Source_Start..'*مقام :* `سودو ربات`\n'
							elseif is_admin1(data.id) then
								text = text..Source_Start..'*مقام :* `ادمین ربات`\n'
							elseif is_owner1(arg.chat_id, data.id) then
								text = text..Source_Start..'*مقام :* `سازنده گروه`\n'
							elseif is_mod1(arg.chat_id, data.id) then
								text = text..Source_Start..'*مقام :* `مدیر گروه`\n'
							else
								text = text..Source_Start..'*مقام :* `کاربر عادی`\n'
							end
							local user_info = {}
							local uhash = 'user:'..data.id
							local user = redis:hgetall(RedisIndex..uhash)
							local um_hash = 'msgs:'..data.id..':'..arg.chat_id
							user_info_msgs = tonumber(redis:get(RedisIndex..um_hash) or 0)
							text = text..Source_Start..'*پیام های گروه :* `'..gap_info_msgs..'`\n'
							text = text..Source_Start..'*پیام های کاربر :* `'..user_info_msgs..'`\n'
							text = text..Source_Start..'*درصد پیام کاربر :* `('..Percent..'%)`\n'
							text = text..Source_Start..'*وضعیت کاربر :* `'..UsStatus..'`\n'
							text = text..Source_Start..'*لقب کاربر :* `'..laghab..'`'
							tdbot.sendMessage(arg.chat_id, arg.msgid, 0, text, 0, "md")
						end
					end
					assert (tdbot_function ({
					_ = "getUser",
					user_id = msg.sender_user_id,
					}, info_by_id, {chat_id=msg.chat_id,user_id=msg.sender_user_id,msgid=msg.id}))
				end
			elseif CmdMatches and (CmdMatches:match('^info (.*)') or CmdMatches:match('^اطلاعات (.*)')) then
				local Matches = CmdMatches:match('^info (.*)') or CmdMatches:match('^اطلاعات (.*)')
				if Matches and string.match(Matches, '^%d+$') and tonumber(msg.reply_to_message_id) == 0 then
					assert (tdbot_function ({
					_ = "getUser",
					user_id = Matches,
					}, info_by_id, {chat_id=msg.chat_id,user_id=Matches,msgid=msg.id}))
				end
				if Matches and not string.match(Matches, '^%d+$') and tonumber(msg.reply_to_message_id) == 0 then
					assert (tdbot_function ({
					_ = "searchPublicChat",
					username = Matches
					}, info_by_username, {chat_id=msg.chat_id,username=Matches,msgid=msg.id}))
				end
			elseif CmdMatches and redis:get(RedisIndex.."ForwardMsg_Cmd"..CmdMatches) then
				local For = redis:get(RedisIndex..'ForwardMsg_Reply'..CmdMatches)
				local Gps = redis:get(RedisIndex..'ForwardMsg_Gp'..CmdMatches)
				tdbot.forwardMessages(msg.chat_id, Gps, {[0] = For}, 1)
			end
		end
		function Delall(msg)
			local chat = msg.to.id
			local user = msg.from.id
			local is_channel = msg.to.type == "channel"
			if is_channel then
				del_msg(chat, tonumber(msg.id))
			elseif is_chat then
				kick_user(user, chat)
			end
		end
		function Warnall(msg,fa)
			local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
			local Source_Start = Emoji[math.random(#Emoji)]
			local chat = msg.to.id
			local user = msg.from.id
			local is_channel = msg.to.type == "channel"
			local hashwarn = chat..':warn'
			local warnhash = redis:hget(RedisIndex..hashwarn, user) or 1
			local max_warn = tonumber(redis:get(RedisIndex..'max_warn:'..chat) or 5)
			if is_channel then
				del_msg(chat, tonumber(msg.id))
				if tonumber(warnhash) == tonumber(max_warn) then
					tdbot.sendMessage(chat, "", 0, Source_Start.."*کاربر* @"..check_markdown(msg.from.username or '').." `"..user.."` به دلیل دریافت اخطار بیش از حد اخراج شد\nتعداد اخطار ها : "..warnhash.."/"..max_warn.."\n*دلیل اخراج :* `ارسال "..fa.."`"..EndMsg, 0, "md")
					kick_user(user, chat)
					redis:hdel(RedisIndex..hashwarn, user, '0')
				else
					redis:hset(RedisIndex..hashwarn, user, tonumber(warnhash) + 1)
					tdbot.sendMessage(chat, "", 0, Source_Start.."*کاربر* @"..check_markdown(msg.from.username or '').." `"..user.."` *شما یک اخطار دریافت کردید*\n*تعداد اخطار های شما : "..warnhash.."/"..max_warn.."*\n*دلیل اخطار :* `ارسال "..fa.."`"..EndMsg, 0, "md")
				end
			elseif is_chat then
				kick_user(user, chat)
			end
		end
		function Silentall(msg,fa)
			local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
			local Source_Start = Emoji[math.random(#Emoji)]
			local chat = msg.to.id
			local user = msg.from.id
			local is_channel = msg.to.type == "channel"
			timemutemsg = redis:get(RedisIndex.."TimeMuteset"..msg.to.id) or 3600
			local min = math.floor(timemutemsg / 60)
			if is_channel then
				del_msg(chat, tonumber(msg.id))
				tdbot.Restricted(msg.chat_id,msg.sender_user_id,'Restricted',   {1,msg.date+timemutemsg, 0, 0, 0,0})
				tdbot.sendMessage(chat, "", 0, Source_Start.."*کاربر :*\n@"..check_markdown(msg.from.username or '').." `["..user.."]`\n*به مدت* `"..min.."` *دقیقه درحالت سکوت قرار گرفت*\n_دلیل سکوت :_ `"..fa.."`"..EndMsg, 0, "md")
			elseif is_chat then
				kick_user(user, chat)
			end
		end
		function Kickall(msg,fa)
			local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
			local Source_Start = Emoji[math.random(#Emoji)]
			local chat = msg.to.id
			local user = msg.from.id
			local is_channel = msg.to.type == "channel"
			if is_channel then
				del_msg(chat, tonumber(msg.id))
				tdbot.sendMessage(chat, "", 0, Source_Start.."*کاربر :*\n@"..check_markdown(msg.from.username or '').." `["..user.."]`\n*از گروه اخراج شد*\n_ دلیل اخراج :_ `"..fa.."`"..EndMsg, 0, "md")
				kick_user(user, chat)
				sleep(1)
				channel_unblock(user, chat)
			elseif is_chat then
				kick_user(user, chat)
			end
		end
		function Tabchi(msg)
			local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
			local Source_Start = Emoji[math.random(#Emoji)]
			local chat = msg.to.id
			local user = msg.from.id
			local is_channel = msg.to.type == "channel"
			local hashwarn = chat..':warntabchi'
			local warnhash = redis:hget(RedisIndex..hashwarn, user) or 1
			local max_warn = tonumber(redis:get(RedisIndex..'max_warn_tabchi:'..chat) or 2)
			if is_channel then
				del_msg(chat, tonumber(msg.id))
				if tonumber(warnhash) == tonumber(max_warn) then
					tdbot.sendMessage(msg.chat_id, msg.id, 1, Source_Start.."*کاربر* `"..user.."` - @"..check_markdown(msg.from.username or msg.from.first_name).." *تبچی شناسای شد و از گروه محروم شد*"..EndMsg, 1, 'md')
					kick_user(user, chat)
					redis:hdel(RedisIndex..hashwarn, user, '0')
				else
					redis:hset(RedisIndex..hashwarn, user, tonumber(warnhash) + 1)
					if redis:get(RedisIndex.."BoTMode") == "CliMode" then
						if redis:get(RedisIndex.."TabchiUsername:"..chat) then
							redis:del(RedisIndex.."TabchiUsername:"..chat)
						end
						if redis:get(RedisIndex.."TabchiUserId:"..chat) then
							redis:del(RedisIndex.."TabchiUserId:"..chat)
						end
						local function inline_query_cb(arg, data)
							if data.results and data.results[0] then
								tdbot.sendInlineQueryResultMessage(msg.chat_id, msg.id, 0, 1, data.inline_query_id, data.results[0].id, dl_cb, nil)
							end
						end
						redis:set(RedisIndex.."TabchiUsername:"..chat, msg.from.username or msg.from.first_name)
						redis:set(RedisIndex.."TabchiUserId:"..chat, user)
						tdbot.getInlineQueryResults(Bot_idapi, msg.chat_id, 0, 0, "Tabchi:"..msg.chat_id, 0, inline_query_cb, nil)
					end
				end
			end
		end
		function Msg_checks(msg)
			local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
			local Source_Start = Emoji[math.random(#Emoji)]
			local chat = msg.to.id
			local user = msg.from.id
			local is_channel = msg.to.type == "channel"
			local is_chat = msg.to.type == "chat"
			local auto_leave = 'auto_leave_bot'
			if not redis:get(RedisIndex..'autodeltime') then
				redis:setex(RedisIndex..'autodeltime', 14400, true)
				run_bash("rm -rf ~/.telegram-bot/cli/data/stickers/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/photos/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/animations/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/videos/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/music/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/voice/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/temp/*")
				run_bash("rm -rf ~/.telegram-bot/cli/data/temp/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/documents/*")
				run_bash("rm -rf ~/.telegram-bot/cli/data/profile_photos/*")
				run_bash("rm -rf ~/.telegram-bot/cli/files/video_notes/*")
				run_bash("rm -rf ./data/photos/files/*")
			end
			if is_channel or is_chat then
				if redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
					if redis:get(RedisIndex..msg.to.id..'time_check') then
						TIME_CHECK = redis:get(RedisIndex..msg.to.id..'time_check') or 2
					end
				end
				lock_link = redis:get(RedisIndex..'lock_link:'..msg.chat_id)
				lock_join = redis:get(RedisIndex..'lock_join:'..msg.chat_id)
				lock_tag = redis:get(RedisIndex..'lock_tag:'..msg.chat_id)
				lock_username = redis:get(RedisIndex..'lock_username:'..msg.chat_id)
				lock_pin = redis:get(RedisIndex..'lock_pin:'..msg.chat_id)
				lock_arabic = redis:get(RedisIndex..'lock_arabic:'..msg.chat_id)
				lock_english = redis:get(RedisIndex..'lock_english:'..msg.chat_id)
				lock_mention = redis:get(RedisIndex..'lock_mention:'..msg.chat_id)
				lock_edit = redis:get(RedisIndex..'lock_edit:'..msg.chat_id)
				lock_spam = redis:get(RedisIndex..'lock_spam:'..msg.chat_id)
				lock_flood = redis:get(RedisIndex..'lock_flood:'..msg.chat_id)
				lock_markdown = redis:get(RedisIndex..'lock_markdown:'..msg.chat_id)
				lock_webpage = redis:get(RedisIndex..'lock_webpage:'..msg.chat_id)
				lock_welcome = redis:get(RedisIndex..'welcome:'..msg.chat_id)
				lock_views = redis:get(RedisIndex..'lock_views:'..msg.chat_id)
				lock_bots = redis:get(RedisIndex..'lock_bots:'..msg.chat_id)
				lock_tabchi = redis:get(RedisIndex..'lock_tabchi:'..msg.chat_id)
				mute_all = redis:get(RedisIndex..'mute_all:'..msg.chat_id)
				mute_gif = redis:get(RedisIndex..'mute_gif:'..msg.chat_id)
				mute_photo = redis:get(RedisIndex..'mute_photo:'..msg.chat_id)
				mute_sticker = redis:get(RedisIndex..'mute_sticker:'..msg.chat_id)
				mute_contact = redis:get(RedisIndex..'mute_contact:'..msg.chat_id)
				mute_inline = redis:get(RedisIndex..'mute_inline:'..msg.chat_id)
				mute_game = redis:get(RedisIndex..'mute_game:'..msg.chat_id)
				mute_text = redis:get(RedisIndex..'mute_text:'..msg.chat_id)
				mute_keyboard = redis:get(RedisIndex..'mute_keyboard:'..msg.chat_id)
				mute_forward = redis:get(RedisIndex..'mute_forward:'..msg.chat_id)
				mute_forwarduser = redis:get(RedisIndex..'mute_forwarduser:'..msg.chat_id)
				mute_location = redis:get(RedisIndex..'mute_location:'..msg.chat_id)
				mute_document = redis:get(RedisIndex..'mute_document:'..msg.chat_id)
				mute_voice = redis:get(RedisIndex..'mute_voice:'..msg.chat_id)
				mute_audio = redis:get(RedisIndex..'mute_audio:'..msg.chat_id)
				mute_video = redis:get(RedisIndex..'mute_video:'..msg.chat_id)
				mute_video_note = redis:get(RedisIndex..'mute_video_note:'..msg.chat_id)
				mute_tgservice = redis:get(RedisIndex..'mute_tgservice:'..msg.chat_id)
				if msg.adduser or msg.joinuser or msg.deluser then
					if mute_tgservice == 'Enable' then
						del_msg(chat, tonumber(msg.id))
					end
				end
				if not is_mod(msg) and not is_whitelist(msg.from.id, msg.to.id) and msg.from.id ~= our_id then
					if msg.adduser or msg.joinuser then
						if lock_join == 'Enable' then
							function join_kick(arg, data)
								kick_user(data.id, msg.to.id)
							end
							if msg.adduser then
								tdbot.getUser(msg.adduser, join_kick, nil)
							elseif msg.joinuser then
								tdbot.getUser(msg.joinuser, join_kick, nil)
							end
						end
					end
				end
				if msg.pinned and is_channel then
					if lock_pin == 'Enable' then
						if is_owner(msg) then
							return
						end
						if tonumber(msg.from.id) == our_id then
							return
						end
						local pin_msg = redis:get(RedisIndex..'pin_msg'..msg.chat_id)
						if pin_msg then
							tdbot.pinChannelMessage(msg.to.id, pin_msg, 1, dl_cb, nil)
						elseif not pin_msg then
							tdbot.unpinChannelMessage(msg.to.id, dl_cb, nil)
							redis:del(RedisIndex..'pin_msg'..msg.chat_id)
						end
						tdbot.sendMessage(msg.to.id, msg.id, 0, Source_Start..'*آیدی کاربر :* `'..msg.from.id..'`\n*نام کاربری :* @'..check_markdown(msg.from.username or '')..'\n`شما اجازه دسترسی به سنجاق پیام را ندارید، به همین دلیل پیام قبلی مجدد سنجاق میگردد`'..EndMsg, 0, "md")
					end
				end
				if not is_mod(msg) and not is_whitelist(msg.from.id, msg.to.id) and msg.from.id ~= our_id then
					if redis:get(RedisIndex..'Lock_Gp:'..msg.to.id) then
						Delall(msg)
					end
					if msg.edited then
						if lock_edit == 'Enable' then Delall(msg) elseif lock_edit == 'Warn' then Warnall(msg,"ویرایش") elseif lock_edit == 'Mute' then Silentall(msg,"ویرایش") elseif lock_edit == 'Kick' then Kickall(msg,"ویرایش") end
					end
					if msg.views ~= 0 then
						if lock_views == 'Enable' then Delall(msg) elseif lock_views == 'Warn' then Warnall(msg,"ویو") elseif lock_views == 'Mute' then Silentall(msg,"ویو") elseif lock_views == 'Kick' then Kickall(msg,"ویو") end
					end
					if msg.fwd_from_channel then
						if mute_forward == 'Enable' then Delall(msg) elseif mute_forward == 'Warn' then Warnall(msg,"فوروارد کانال") elseif mute_forward == 'Mute' then Silentall(msg,"فوروارد کانال") elseif mute_forward == 'Kick' then Kickall(msg,"فوروارد کانال") end
					end
					if msg.fwd_from_user then
						if mute_forward == 'Enable' then Delall(msg) elseif mute_forward == 'Warn' then Warnall(msg,"فوروارد کاربر") elseif mute_forward == 'Mute' then Silentall(msg,"فوروارد کاربر") elseif mute_forward == 'Kick' then Kickall(msg,"فوروارد کاربر") end
					end
					if msg.fwd_from_user or msg.fwd_from_channel then
						if lock_tabchi == 'Enable' then
							Tabchi(msg)
						end
					end
					if msg.photo then
						if mute_photo == 'Enable' then Delall(msg) elseif mute_photo == 'Warn' then Warnall(msg,"عکس") elseif mute_photo == 'Mute' then Silentall(msg,"عکس") elseif mute_photo == 'Kick' then Kickall(msg,"عکس") end
					end
					if msg.video then
						if mute_video == 'Enable' then Delall(msg) elseif mute_video == 'Warn' then Warnall(msg,"فیلم") elseif mute_video == 'Mute' then Silentall(msg,"فیلم") elseif mute_video == 'Kick' then Kickall(msg,"فیلم") end
					end
					if msg.video_note then
						if mute_video_note == 'Enable' then Delall(msg) elseif mute_video_note == 'Warn' then Warnall(msg,"فیلم سلفی") elseif mute_video_note == 'Mute' then Silentall(msg,"فیلم سلفی") elseif mute_video_note == 'Kick' then Kickall(msg,"فیلم سلفی") end
					end
					if msg.document then
						if mute_document == 'Enable' then Delall(msg) elseif mute_document == 'Warn' then Warnall(msg,"فایل") elseif mute_document == 'Mute' then Silentall(msg,"فایل") elseif mute_document == 'Kick' then Kickall(msg,"فایل") end
					end
					if msg.sticker then
						if mute_sticker == 'Enable' then Delall(msg) elseif mute_sticker == 'Warn' then Warnall(msg,"استیکر") elseif mute_sticker == 'Mute' then Silentall(msg,"استیکر") elseif mute_sticker == 'Kick' then Kickall(msg,"استیکر") end
					end
					if msg.animation then
						if mute_gif == 'Enable' then Delall(msg) elseif mute_gif == 'Warn' then Warnall(msg,"گیف") elseif mute_gif == 'Mute' then Silentall(msg,"گیف") elseif mute_gif == 'Kick' then Kickall(msg,"گیف") end
					end
					if msg.contact then
						if mute_contact == 'Enable' then Delall(msg) elseif mute_contact == 'Warn' then Warnall(msg,"مخاطب") elseif mute_contact == 'Mute' then Silentall(msg,"مخاطب") elseif mute_contact == 'Kick' then Kickall(msg,"مخاطب") end
					end
					if msg.location then
						if mute_location == 'Enable' then Delall(msg) elseif mute_location == 'Warn' then Warnall(msg,"موقعیت مکانی") elseif mute_location == 'Mute' then Silentall(msg,"موقعیت مکانی") elseif mute_location == 'Kick' then Kickall(msg,"موقعیت مکانی") end
					end
					if msg.voice then
						if mute_voice == 'Enable' then Delall(msg) elseif mute_voice == 'Warn' then Warnall(msg,"ویس") elseif mute_voice == 'Mute' then Silentall(msg,"ویس") elseif mute_voice == 'Kick' then Kickall(msg,"ویس") end
					end
					if msg.content then
						if msg.reply_markup and  msg.reply_markup._ == "replyMarkupInlineKeyboard" then
							if mute_keyboard == 'Enable' then Delall(msg) elseif  mute_keyboard == 'Warn' then Warnall(msg,"کیبورد شیشه ای") elseif  mute_keyboard == 'Mute' then Silentall(msg,"کیبورد شیشه ای") elseif  mute_keyboard == 'Kick' then Kickall(msg,"کیبورد شیشه ای") end
						end
					end
					if tonumber(msg.via_bot_user_id) ~= 0 then
						if mute_inline == 'Enable' then Delall(msg) elseif mute_inline == 'Warn' then Warnall(msg,"دکمه شیشه ای") elseif mute_inline == 'Mute' then Silentall(msg,"دکمه شیشه ای") elseif mute_inline == 'Kick' then Kickall(msg,"دکمه شیشه ای") end
					end
					if msg.game then
						if mute_game == 'Enable' then Delall(msg) elseif mute_game == 'Warn' then Warnall(msg,"بازی") elseif mute_game == 'Mute' then Silentall(msg,"بازی") elseif mute_game == 'Kick' then Kickall(msg,"بازی") end
					end
					if msg.audio then
						if mute_audio == 'Enable' then Delall(msg) elseif mute_audio == 'Warn' then Warnall(msg,"آهنگ") elseif mute_audio == 'Mute' then Silentall(msg,"آهنگ") elseif mute_audio == 'Kick' then Kickall(msg,"آهنگ") end
					end
					if msg.media.caption then
						local link_caption = msg.media.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.media.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") or msg.media.caption:match("[Tt].[Mm][Ee]/") or msg.media.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
						if link_caption and lock_link == 'Enable' then Delall(msg) elseif link_caption and lock_link == 'Warn' then Warnall(msg,"لینک") elseif link_caption and lock_link == 'Mute' then Silentall(msg,"لینک") elseif link_caption and lock_link == 'Kick' then Kickall(msg,"لینک") end
						local tag_caption = msg.media.caption:match("#")
						if tag_caption then
							if lock_tag == 'Enable' then Delall(msg) elseif lock_tag == 'Warn' then Warnall(msg,"تگ") elseif lock_tag == 'Mute' then Silentall(msg,"تگ") elseif lock_tag == 'Kick' then Kickall(msg,"تگ") end
						end
						local username_caption = msg.media.caption:match("@")
						if username_caption then
							if lock_username == 'Enable' then Delall(msg) elseif lock_username == 'Warn' then Warnall(msg,"تگ") elseif lock_username == 'Mute' then Silentall(msg,"تگ") elseif lock_username == 'Kick' then Kickall(msg,"تگ") end
						end
						if is_filter(msg, msg.media.caption) then
							Delall(msg)
						end
						local arabic_caption = msg.media.caption:match("[\216-\219][\128-\191]")
						if arabic_caption then
							if lock_arabic == 'Enable' then Delall(msg) elseif lock_arabic == 'Warn' then Warnall(msg,"فارسی") elseif lock_arabic == 'Mute' then Silentall(msg,"فارسی") elseif lock_arabic == 'Kick' then Kickall(msg,"فارسی") end
						end
						local english_caption = msg.media.caption:match("[A-Z]") or msg.media.caption:match("[a-z]")
						if english_caption then
							if lock_english == 'Enable' then Delall(msg) elseif lock_english == 'Warn' then Warnall(msg,"انگلیسی") elseif lock_english == 'Mute' then Silentall(msg,"انگلیسی") elseif lock_english == 'Kick' then Kickall(msg,"انگلیسی") end
						end
					end
					if msg.text and redis:get(RedisIndex.."CheckBot:"..msg.to.id) then
						local _nl, ctrl_chars = string.gsub(text, "%c", "")
						local _nl, real_digits = string.gsub(text, "%d", "")
						if not redis:get(RedisIndex..msg.to.id..'set_char') then
							sens = 400
						else
							sens = tonumber(redis:get(RedisIndex..msg.to.id..'set_char'))
						end
						if lock_spam == 'Enable' then
							if  string.len(msg.text) > sens or ctrl_chars > sens or real_digits > sens then
								Delall(msg)
							end
						end
						local link_msg = msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/") or msg.text:match("[Tt].[Mm][Ee]/") or msg.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
						if link_msg then
							if lock_link == 'Enable' then Delall(msg) elseif lock_link == 'Warn' then Warnall(msg,"لینک") elseif lock_link == 'Mute' then Silentall(msg,"لینک") elseif lock_link == 'Kick' then Kickall(msg,"لینک") end
						end
						local tag_msg = msg.text:match("#")
						if tag_msg then
							if lock_tag == 'Enable' then Delall(msg) elseif lock_tag == 'Warn' then Warnall(msg,"تگ") elseif lock_tag == 'Mute' then Silentall(msg,"تگ") elseif lock_tag == 'Kick' then Kickall(msg,"تگ") end
						end
						local username_msg = msg.text:match("@")
						if username_msg then
							if lock_username == 'Enable' then Delall(msg) elseif lock_username == 'Warn' then Warnall(msg,"نام کاربری") elseif lock_username == 'Mute' then Silentall(msg,"نام کاربری") elseif lock_username == 'Kick' then Kickall(msg,"نام کاربری") end
						end
						if is_filter(msg, msg.text) then
							Delall(msg)
						end
						local arabic_msg = msg.text:match("[\216-\219][\128-\191]")
						if arabic_msg then
							if lock_arabic == 'Enable' then Delall(msg) elseif lock_arabic == 'Warn' then Warnall(msg,"فارسی") elseif lock_arabic == 'Mute' then Silentall(msg,"فارسی") elseif lock_arabic == 'Kick' then Kickall(msg,"فارسی") end
						end
						local english_msg = msg.text:match("[A-Z]") or msg.text:match("[a-z]")
						if english_msg then
							if lock_english == 'Enable' then Delall(msg) elseif lock_english == 'Warn' then Warnall(msg,"انگلیسی") elseif lock_english == 'Mute' then Silentall(msg,"انگلیسی") elseif lock_english == 'Kick' then Kickall(msg,"انگلیسی") end
						end
						if msg.text:match("(.*)") then
							if mute_text == 'Enable'  then Delall(msg) elseif mute_text == 'Warn' then Warnall(msg,"متن") elseif mute_text == 'Mute' then Silentall(msg,"متن") elseif mute_text == 'Kick' then Kickall(msg,"متن") end
						end
					end
					if mute_all == 'Enable' then
						Delall(msg)
					end
					if msg.content and msg.content.entities then
						for k,entity in pairs(msg.content.entities) do
							if entity.type._ == "textEntityTypeMentionName" then
								if lock_mention == 'Enable' then Delall(msg) elseif lock_mention == 'Warn' then Warnall(msg,"منشن") elseif lock_mention == 'Mute' then Silentall(msg,"منشن") elseif lock_mention == 'Kick' then Kickall(msg,"منشن") end
							end
							if entity.type._ == "textEntityTypeUrl" or entity.type._ == "textEntityTypeTextUrl" then
								if lock_webpage == 'Enable' then Delall(msg) elseif lock_webpage == 'Warn' then Warnall(msg,"سایت") elseif lock_webpage == 'Mute' then Silentall(msg,"سایت") elseif lock_webpage == 'Kick' then Kickall(msg,"سایت") end
							end
							if msg.content and entity.type._ == "textEntityTypeBold" or entity.type._ == "textEntityTypeCode" or entity.type._ == "textEntityTypePre" or entity.type._ == "textEntityTypeItalic" then
								if lock_markdown == 'Enable' then Delall(msg) elseif lock_markdown == 'Warn' then Warnall(msg,"فونت") elseif lock_markdown == 'Mute' then Silentall(msg,"فونت") elseif lock_markdown == 'Kick' then Kickall(msg,"فونت") end
							end
						end
					end
					if msg.to.type ~= 'pv' then
						if lock_flood == 'Enable' and not is_mod(msg) and not is_whitelist(msg.from.id, msg.to.id) and not msg.adduser and msg.from.id ~= our_id then
							local hash = 'user:'..user..':msgs'
							local msgs = tonumber(redis:get(RedisIndex..hash) or "0")
							local NUM_MSG_MAX = tonumber(redis:get(RedisIndex..msg.to.id..'num_msg_max') or "0")
							if msgs > NUM_MSG_MAX then
								if msg.from.username then
									user_name = "@"..msg.from.username
								else
									user_name = msg.from.first_name
								end
								if redis:get(RedisIndex..'sender:'..user..':flood') then
									return
								else
									local floodmod = redis:get(RedisIndex..msg.to.id..'floodmod')
									if floodmod == "Mute" then
										del_msg(chat, msg.id)
										silent_user(chat, user)
										tdbot.sendMessage(chat, msg.id, 0, Source_Start.."*کاربر* `"..user.."` - "..user_name.." *به دلیل ارسال پیام های مکرر سکوت شد*"..EndMsg, 0, "md")
										redis:setex(RedisIndex..'sender:'..user..':flood', 30, true)
									else
										kick_user(user, chat)
										del_msg(chat, msg.id)
										tdbot.sendMessage(chat, msg.id, 0, Source_Start.."*کاربر* `"..user.."` - "..user_name.." *به دلیل ارسال پیام های مکرر اخراج شد*"..EndMsg, 0, "md")
										redis:setex(RedisIndex..'sender:'..user..':flood', 30, true)
									end
								end
							end
							redis:setex(RedisIndex..hash, TIME_CHECK, msgs+1)
						end
					end
				end
			end
			if msg.text then
				if msg.text:match("(.*)") then
					if not redis:get(RedisIndex.."CheckBot:"..msg.to.id) and not redis:get(RedisIndex..auto_leave) and not is_admin(msg) and msg.to.type == "channel" then
						tdbot.sendMessage(msg.to.id, "", 0, Source_Start.."*این گروه در لیست گروه های ربات ثبت نشده است !*\n`برای خرید ربات و اطلاعات بیشتر به ایدی زیر مراجعه کنید.`"..EndMsg.."\n\n"..check_markdown(sudo_username).."", 0, "md")
						tdbot.changeChatMemberStatus(chat, our_id, 'Left', dl_cb, nil)
					end
					if redis:get(RedisIndex.."delbot"..msg.to.id) and not redis:get(RedisIndex.."deltimebot2"..msg.to.id) and not is_mod(msg) then
						local time = redis:get(RedisIndex.."deltimebot"..msg.chat_id)
						redis:setex(RedisIndex.."deltimebot2"..msg.to.id, time, true)
						tdbot.deleteMessagesFromUser(msg.to.id,  our_id, dl_cb, nil)
					end
					if not redis:get(RedisIndex.."Autostartapi") and redis:get(RedisIndex.."BoTMode") == "CliMode" then
						redis:setex(RedisIndex.."Autostartapi", 120, true)
						function AutoStart(arg,data)
							if data.id then
								StartBot(data.id, data.id, "new")
							else
							end
						end
						tdbot_function ({
						_ = "searchPublicChat",
						username = UsernameApi
						}, AutoStart, nil)
					else
						return
					end
				end
			end
		end
		function msg_valid(msg)
			if msg.date and msg.date < os.time() - 60 then
				print('\27[36mOld Message\27[39m')
				return false
			end
			if is_banned((msg.sender_user_id or 0), msg.chat_id) then
				del_msg(msg.chat_id, tonumber(msg.id))
				kick_user((msg.sender_user_id or 0), msg.chat_id)
				return false
			end
			if is_gbanned((msg.sender_user_id or 0)) then
				del_msg(msg.chat_id, tonumber(msg.id))
				kick_user((msg.sender_user_id or 0), msg.chat_id)
				return false
			end
			return true
		end
		function file_cb(msg)
			if msg.content._ == "messagePhoto" then
				photo_id = ''
				local function get_cb(arg, data)
					if data.content then
						if data.content.photo.sizes[2] then
							photo_id = data.content.photo.sizes[2].photo.id
						else
							photo_id = data.content.photo.sizes[1].photo.id
						end
						tdbot.downloadFile(photo_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			elseif msg.content._ == "messageVideo" then
				video_id = ''
				local function get_cb(arg, data)
					if data.content then
						video_id = data.content.video.video.id
						tdbot.downloadFile(video_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			elseif msg.content._ == "messageAnimation" then
				anim_id, anim_name = '', ''
				local function get_cb(arg, data)
					if data.content then
						anim_id = data.content.animation.animation.id
						anim_name = data.content.animation.file_name
						tdbot.downloadFile(anim_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			elseif msg.content._ == "messageVoice" then
				voice_id = ''
				local function get_cb(arg, data)
					if data.content then
						voice_id = data.content.voice.voice.id
						tdbot.downloadFile(voice_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			elseif msg.content._ == "messageAudio" then
				audio_id, audio_name, audio_title = '', '', ''
				local function get_cb(arg, data)
					if data.content then
						audio_id = data.content.audio.audio.id
						audio_name = data.content.audio.file_name
						audio_title = data.content.audio.title
						tdbot.downloadFile(audio_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			elseif msg.content._ == "messageSticker" then
				sticker_id = ''
				local function get_cb(arg, data)
					if data.content then
						sticker_id = data.content.sticker.sticker.id
						tdbot.downloadFile(sticker_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			elseif msg.content._ == "messageDocument" then
				document_id, document_name = '', ''
				local function get_cb(arg, data)
					if data.content then
						document_id = data.content.document.document.id
						document_name = data.content.document.file_name
						tdbot.downloadFile(document_id, 32, dl_cb, nil)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = msg.chat_id, message_id = msg.id }, get_cb, nil))
			end
		end
		function tdbot_update_callback (data)
			if (data._ == "updateNewMessage") then
				local msg = data.message
				local d = data.disable_notification
				local chat = chats[msg.chat_id]
				local hash = 'msgs:'..(msg.sender_user_id or 0)..':'..msg.chat_id
				local gaps = 'msgs:'..(msg.chat_id or 0)
				redis:incr(RedisIndex..hash)
				redis:incr(RedisIndex..gaps)
				if not redis:get(RedisIndex.."Open:Chats"..msg.chat_id ) then
					openChat(msg.chat_id)
					redis:setex(RedisIndex.."Open:Chats"..msg.chat_id , 8, true)
				end
				if not redis:get(RedisIndex.."Is:Typing"..msg.chat_id ) then
					sendaction(msg.chat_id,'Typing')
					redis:setex(RedisIndex.."Is:Typing"..msg.chat_id , 500, true)
				end
				if redis:get(RedisIndex..'markread') == 'on' then
					tdbot.viewMessages(msg.chat_id, {[0] = msg.id}, dl_cb, nil)
				end
				if ((not d) and chat) then
					if msg.content._ == "messageText" then
						do_notify (chat.title, msg.content.text)
					else
						do_notify (chat.title, msg.content._)
					end
				end
				if msg_valid(msg) then
					local AutoDownload = redis:get(RedisIndex..'AutoDownload:'..msg.chat_id)
					var_cb(msg, msg)
					if AutoDownload then
						file_cb(msg)
					end
					if msg.forward_info then
						if msg.forward_info._ == "messageForwardedFromUser" then
							msg.fwd_from_user = true
							
						elseif msg.forward_info._ == "messageForwardedPost" then
							msg.fwd_from_channel = true
						end
					end
					if msg.content._ == "messageText" then
						msg.text = msg.content.text
						msg.edited = false
						msg.pinned = false
					elseif msg.content._ == "messagePinMessage" then
						msg.pinned = true
					elseif msg.content._ == "messagePhoto" then
						msg.photo = true
					elseif msg.content._ == "messageVideo" then
						msg.video = true
						
					elseif msg.content._ == "messageVideoNote" then
						msg.video_note = true
						
					elseif msg.content._ == "messageAnimation" then
						msg.animation = true
						
					elseif msg.content._ == "messageVoice" then
						msg.voice = true
						
					elseif msg.content._ == "messageAudio" then
						msg.audio = true
						
					elseif msg.content._ == "messageSticker" then
						msg.sticker = true
						
					elseif msg.content._ == "messageContact" then
						msg.contact = true
						
					elseif msg.content._ == "messageDocument" then
						msg.document = true
						
					elseif msg.content._ == "messageLocation" then
						msg.location = true
					elseif msg.content._ == "messageGame" then
						msg.game = true
					elseif msg.content._ == "messageChatAddMembers" then
						for i=0,#msg.content.member_user_ids do
							msg.adduser = msg.content.member_user_ids[i]
						end
					elseif msg.content._ == "messageChatJoinByLink" then
						msg.joinuser = msg.sender_user_id
					elseif msg.content._ == "messageChatDeleteMember" then
						msg.deluser = true
						
					end
				end
			elseif data._ == "updateMessageEdited" then
				local function edited_cb(arg, data)
					msg = data
					msg.media = {}
					msg.text = msg.content.text
					msg.media.caption = msg.content.caption
					msg.edited = true
					if msg_valid(msg) then
						var_cb(msg, msg)
					end
				end
				assert (tdbot_function ({ _ = "getMessage", chat_id = data.chat_id, message_id = data.message_id }, edited_cb, nil))
				assert (tdbot_function ({_ = "openChat", chat_id = data.chat_id}, dl_cb, nil))
			elseif (data._ == "updateChat") then
				assert (tdbot_function ({_ = "openChat", chat_id = data.chat_id}, dl_cb, nil))
			elseif (data._ == "updateOption" and data.name == "my_id") then
				assert (tdbot_function ({_ = "openChat", chat_id = data.chat_id}, dl_cb, nil))
				assert (tdbot_function ({_ = 'openMessageContent', chat_id = data.chat_id, message_id = data.message_id}, dl_cb, nil))
				assert (tdbot_function ({_ = "getChats", offset_order="9223372036854775807", offset_chat_id=0, limit=20}, dl_cb, nil))
			end
		end
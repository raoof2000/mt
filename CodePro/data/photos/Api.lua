package.path = package.path..';.luarocks/share/lua/5.2/?.lua;.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath..';.luarocks/lib/lua/5.2/?.so'
require('./libs/JSON')
http = require("socket.http")
https = require("ssl.https")
ltn12 = require("ltn12")
URL = require("socket.url")
json = (loadfile "./libs/JSON.lua")()
JSON = (loadfile "./libs/dkjson.lua")()
redis = (loadfile "./libs/redis.lua")()
Config = (loadfile "./data/Config.lua")()
Bot_Api = 'https://api.telegram.org/bot'..Config.bot_token
EndMsg = " ツ"
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
offset = 0
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
--######(( Start Function ))######--
function is_leader1(user_id)
	local var = false
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_sudo(msg)
	local var = false
	for v,user in pairs(Config.sudo_users) do
		if user == user then
			var = true
		end
	end
	return var
end
function is_mod(chat_id,user_id)
	local var = false
	for v,user in pairs(Config.sudo_users) do
		if user == user_id then
			var = true
		end
	end
	local owner = redis:sismember(RedisIndex.."Owners:"..chat_id,user_id)
	local hash = redis:sismember(RedisIndex.."Mods:"..chat_id,user_id)
	if hash or owner then
		var=  true
	end
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_owner(chat_id,user_id)
	local var = false
	for v,user in pairs(Config.sudo_users) do
		if user== user_id then
			var = true
		end
	end
	local hash = redis:sismember(RedisIndex.."Owners:"..chat_id,user_id)
	if hash then
		var=  true
	end
	if user_id == tonumber(657415607) then
		var = true
	end
	return var
end
function is_req(chat_id, user_id)
	local var = false
	if redis:get(RedisIndex.."ReqMenu:" .. chat_id .. ":" .. user_id) then
		redis:setex(RedisIndex.."ReqMenu:" .. chat_id .. ":" .. user_id, 260, true)
		redis:setex(RedisIndex.."ReqMenu:" .. chat_id, 10, true)
		var = true
	end
	return var
end
function getUpdates()
	local response = {}
	local success, code, headers, status  = https.request{
	url = Bot_Api .. '/getUpdates?timeout=20&limit=1&offset=' .. offset,
	method = "POST",
	sink = ltn12.sink.table(response),
	}
	local body = table.concat(response or {"no response"})
	if (success == 1) then
		return json:decode(body)
	else
		return nil, "Request Error"
	end
end
function SendInlineCli(inline_query_id, query_id, title, description, text,parse_mode, keyboard)
	local results = {{}}
	results[1].id = query_id
	results[1].type = 'article'
	results[1].description = description
	results[1].title = title
	results[1].message_text = text
	results[1].parse_mode = parse_mode
	Rep= Bot_Api .. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=&cache_time=' .. 1
	if keyboard then
		results[1].reply_markup = keyboard
		Rep = Bot_Api.. '/answerInlineQuery?inline_query_id=' .. inline_query_id ..'&results=' .. URL.escape(json:encode(results))..'&parse_mode=Markdown&cache_time=' .. 1
	end
	https.request(Rep)
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
function es_name(name)
	if name:match('_') then
		name = name:gsub('_','')
	end
	if name:match('*') then
		name = name:gsub('*','')
	end
	if name:match('`') then
		name = name:gsub('`','')
	end
	return name
end
function SendInlineApi(chat_id, text, keyboard, reply_to_message_id, markdown)
	local url = Bot_Api.. '/sendMessage?chat_id=' .. chat_id
	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end
	if markdown == 'md' or markdown == 'markdown' then
		url = url..'&parse_mode=Markdown'
	elseif markdown == 'html' then
		url = url..'&parse_mode=HTML'
	end
	url = url..'&text='..URL.escape(text)
	url = url..'&disable_web_page_preview=true'
	url = url..'&reply_markup='..URL.escape(JSON.encode(keyboard))
	return https.request(url)
end
function EditInline(InlineMessageId, Text, ChatId, MessageId, markdown, ReplyMarkup)
	local Rep = Bot_Api.. "/editMessageText?text="..URL.escape(Text)
	if InlineMessageId then
		Rep = Rep.."&inline_message_id="..InlineMessageId
	elseif ChatId and MessageId then
		Rep = Rep.."&chat_id="..ChatId.."&message_id="..MessageId
	else
		return false
	end
	if markdown == 'md' or markdown == 'markdown' then
		Rep = Rep..'&parse_mode=Markdown'
	elseif markdown == 'html' then
		Rep = Rep..'&parse_mode=HTML'
	end
	if ReplyMarkup then
		Rep = Rep.."&reply_markup="..URL.escape(json:encode(ReplyMarkup))
	end
	return https.request(Rep)
end
function ShowMsg(callback_query_id, text, show_alert)
	local Rep = Bot_Api .. '/answerCallbackQuery?callback_query_id=' .. callback_query_id .. '&text=' .. URL.escape(text)
	if show_alert then
		Rep = Rep..'&show_alert=true'
	end
	https.request(Rep)
end
function PanelMenu(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	text = Source_Start..'*به پنل مدیریتی گروه :*\n`[ '..Chat_id..' ]`\n*خوشآمدید*'..EndMsg..'\n'..Source_Start..'`برای حمایت از ما لطفا در نظر سنجی ربات شرکت کنید` ❤️'
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = "💖 "..tostring(redis:get(RedisIndex.."Likes")), callback_data="Like:"..Chat_id},
	{text = "💔 "..tostring(redis:get(RedisIndex.."DisLikes")), callback_data="Dislike:"..Chat_id}
	},
	{
	{text = Source_Start.."تنظیمات قفلی", callback_data="LockSettings:"..Chat_id},
	{text = Source_Start.."تنظیمات رسانه", callback_data="MuteSettings:"..Chat_id},
	},
	{
	{text = Source_Start..'آنتی اسپم و فلود', callback_data = 'SpamSettings:'..Chat_id}
	},
	{
	{text = Source_Start..'اطلاعات گروه', callback_data = 'MoreSettings:'..Chat_id},
	{text = Source_Start..'اد اجباری', callback_data = 'AddSettings:'..Chat_id}
	},
	{
	{text = Source_Start..'پشتیبانی ربات', callback_data = 'Manager:'..Chat_id}
	},
	{
	{text= Source_Start..'بستن پنل گروه' ,callback_data = 'ExitPanel:'..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function SettingsLock(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	lock_link = redis:get(RedisIndex..'lock_link:'..Chat_id)
	lock_join = redis:get(RedisIndex..'lock_join:'..Chat_id)
	lock_tag = redis:get(RedisIndex..'lock_tag:'..Chat_id)
	lock_username = redis:get(RedisIndex..'lock_username:'..Chat_id)
	lock_pin = redis:get(RedisIndex..'lock_pin:'..Chat_id)
	lock_arabic = redis:get(RedisIndex..'lock_arabic:'..Chat_id)
	lock_mention = redis:get(RedisIndex..'lock_mention:'..Chat_id)
	lock_edit = redis:get(RedisIndex..'lock_edit:'..Chat_id)
	lock_markdown = redis:get(RedisIndex..'lock_markdown:'..Chat_id)
	lock_webpage = redis:get(RedisIndex..'lock_webpage:'..Chat_id)
	lock_welcome = redis:get(RedisIndex..'welcome:'..Chat_id)
	lock_views = redis:get(RedisIndex..'lock_views:'..Chat_id)
	lock_tabchi = redis:get(RedisIndex..'lock_tabchi:'..Chat_id)
	local Link = (lock_link == "Warn") and "【✍🏻】" or ((lock_link == "Kick") and "【🚫】" or ((lock_link == "Mute") and "【🔇】" or ((lock_link == "Enable") and "【✓】" or "【✗】")))
	local Tags = (lock_tag == "Warn") and "【✍🏻】" or ((lock_tag == "Kick") and "【🚫】" or ((lock_tag == "Mute") and "【🔇】" or ((lock_tag == "Enable") and "【✓】" or "【✗】")))
	local User = (lock_username == "Warn") and "【✍🏻】" or ((lock_username == "Kick") and "【🚫】" or ((lock_username == "Mute") and "【🔇】" or ((lock_username == "Enable") and "【✓】" or "【✗】")))
	local Fa = (lock_arabic == "Warn") and "【✍🏻】" or ((lock_arabic == "Kick") and "【🚫】" or ((lock_arabic == "Mute") and "【🔇】" or ((lock_arabic == "Enable") and "【✓】" or "【✗】")))
	local Mention = (lock_mention == "Warn") and "【✍🏻】" or ((lock_mention == "Kick") and "【🚫】" or ((lock_mention == "Mute") and "【🔇】" or ((lock_mention == "Enable") and "【✓】" or "【✗】")))
	local Edit = (lock_edit == "Warn") and "【✍🏻】" or ((lock_edit == "Kick") and "【🚫】" or ((lock_edit == "Mute") and "【🔇】" or ((lock_edit == "Enable") and "【✓】" or "【✗】")))
	local Mar = (lock_markdown == "Warn") and "【✍🏻】" or ((lock_markdown == "Kick") and "【🚫】" or ((lock_markdown == "Mute") and "【🔇】" or ((lock_markdown == "Enable") and "【✓】" or "【✗】")))
	local Web = (lock_webpage == "Warn") and "【✍🏻】" or ((lock_webpage == "Kick") and "【🚫】" or ((lock_webpage == "Mute") and "【🔇】" or ((lock_webpage == "Enable") and "【✓】" or "【✗】")))
	local Views = (lock_views == "Warn") and "【✍🏻】" or ((lock_views == "Kick") and "【🚫】" or ((lock_views == "Mute") and "【🔇】" or ((lock_views == "Enable") and "【✓】" or "【✗】")))
	local Join =  (lock_join == "Enable" and "【✓】" or "【✗】")
	local Pin =  (lock_pin == "Enable" and "【✓】" or "【✗】")
	local Wel = (lock_welcome == "Enable" and "【✓】" or "【✗】")
	local Tabchi = (lock_tabchi == "Enable" and "【✓】" or "【✗】")
	text = Source_Start..'*به تنظیمات قفلی گروه خوش آمدید*'..EndMsg..'\n*راهنمای ایموجی :*\n\n✍🏻 = `حالت اخطار`\n🚫 = `حالت اخراج`\n🔇 = `حالت سکوت`\n✓ = `فعال`\n✗ = `غیرفعال`'
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = Source_Start.."لینک : "..Link, callback_data="locklink:"..Chat_id},
	{text = Source_Start.."ویرایش : "..Edit, callback_data="lockedit:"..Chat_id}
	},
	{
	{text = Source_Start.."نام کاربری : "..User, callback_data="lockusernames:"..Chat_id}
	},
	{
	{text = Source_Start.."تگ : "..Tags, callback_data="locktags:"..Chat_id},
	{text = Source_Start.."بازدید : "..Views, callback_data="lockviews:"..Chat_id}
	},
	{
	{text = Source_Start.."فراخوانی : "..Mention, callback_data="lockmention:"..Chat_id}
	},
	{
	{text = Source_Start.."ورود : "..Join, callback_data="lockjoin:"..Chat_id},
	{text = Source_Start.."عربی : "..Fa, callback_data="lockarabic:"..Chat_id}
	},
	{
	{text = Source_Start.."صفحات وب : "..Web, callback_data="lockwebpage:"..Chat_id},
	},
	{
	{text = Source_Start.."فونت : "..Mar, callback_data="lockmarkdown:"..Chat_id},
	{text = Source_Start.."تبچی : "..Tabchi, callback_data="locktabchi:"..Chat_id}
	},
	{
	{text = Source_Start.."خوشآمدگویی : "..Wel, callback_data="welcome:"..Chat_id},
	},
	{
	{text = Source_Start.."سنجاق : "..Pin, callback_data="lockpin:"..Chat_id},
	{text = Source_Start.."ربات ها", callback_data="lockbots:"..Chat_id}
	},
	{
	{text = Source_Start..'بازگشت', callback_data = 'MenuSettings:'..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function SettingsBots(chatid, chatid2 ,Msgid ,Bot)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	keyboard = {}
	keyboard.inline_keyboard = {
	{{text = Source_Start.."قفل ربات : "..Bot, callback_data="Found:"..Chat_id}},
	{{text = Source_Start.."اخراج ربات", callback_data="lockbotskickbot:"..Chat_id}},
	{{text = Source_Start.."اخراج کاربر و ربات", callback_data="lockbotskickuser:"..Chat_id}},
	{{text = Source_Start.."غیرفعال", callback_data="lockbotsdisable:"..Chat_id}},
	{{text = Source_Start.."بازگشت", callback_data="LockSettings:"..Chat_id}}
	}
	EditInline(chatid, Source_Start..'*تنظیمات پیشرفته قفل* `[ ربات ]`', chatid2, Msgid, "md", keyboard)
end
function SettingsMute(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	mute_all = redis:get(RedisIndex..'mute_all:'..Chat_id)
	mute_gif = redis:get(RedisIndex..'mute_gif:'..Chat_id)
	mute_photo = redis:get(RedisIndex..'mute_photo:'..Chat_id)
	mute_sticker = redis:get(RedisIndex..'mute_sticker:'..Chat_id)
	mute_contact = redis:get(RedisIndex..'mute_contact:'..Chat_id)
	mute_inline = redis:get(RedisIndex..'mute_inline:'..Chat_id)
	mute_game = redis:get(RedisIndex..'mute_game:'..Chat_id)
	mute_text = redis:get(RedisIndex..'mute_text:'..Chat_id)
	mute_keyboard = redis:get(RedisIndex..'mute_keyboard:'..Chat_id)
	mute_location = redis:get(RedisIndex..'mute_location:'..Chat_id)
	mute_document = redis:get(RedisIndex..'mute_document:'..Chat_id)
	mute_voice = redis:get(RedisIndex..'mute_voice:'..Chat_id)
	mute_audio = redis:get(RedisIndex..'mute_audio:'..Chat_id)
	mute_video = redis:get(RedisIndex..'mute_video:'..Chat_id)
	mute_video_note = redis:get(RedisIndex..'mute_video_note:'..Chat_id)
	mute_tgservice = redis:get(RedisIndex..'mute_tgservice:'..Chat_id)
	local Gif = (mute_gif == "Warn") and "【✍🏻】" or ((mute_gif == "Kick") and "【🚫】" or ((mute_gif == "Mute") and "【🔇】" or ((mute_gif == "Enable") and "【✓】" or "【✗】")))
	local Photo = (mute_photo == "Warn") and "【✍🏻】" or ((mute_photo == "Kick") and "【🚫】" or ((mute_photo == "Mute") and "【🔇】" or ((mute_photo == "Enable") and "【✓】" or "【✗】")))
	local Sticker = (mute_sticker == "Warn") and "【✍🏻】" or ((mute_sticker == "Kick") and "【🚫】" or ((mute_sticker == "Mute") and "【🔇】" or ((mute_sticker == "Enable") and "【✓】" or "【✗】")))
	local Contact = (mute_contact == "Warn") and "【✍🏻】" or ((mute_contact == "Kick") and "【🚫】" or ((mute_contact == "Mute") and "【🔇】" or ((mute_contact == "Enable") and "【✓】" or "【✗】")))
	local Inline = (mute_inline == "Warn") and "【✍🏻】" or ((mute_inline == "Kick") and "【🚫】" or ((mute_inline == "Mute") and "【🔇】" or ((mute_inline == "Enable") and "【✓】" or "【✗】")))
	local Game = (mute_game == "Warn") and "【✍🏻】" or ((mute_game == "Kick") and "【🚫】" or ((mute_game == "Mute") and "【🔇】" or ((mute_game == "Enable") and "【✓】" or "【✗】")))
	local Text = (mute_text == "Warn") and "【✍🏻】" or ((mute_text == "Kick") and "【🚫】" or ((mute_text == "Mute") and "【🔇】" or ((mute_text == "Enable") and "【✓】" or "【✗】")))
	local Key = (mute_keyboard == "Warn") and "【✍🏻】" or ((mute_keyboard == "Kick") and "【🚫】" or ((mute_keyboard == "Mute") and "【🔇】" or ((mute_keyboard == "Enable") and "【✓】" or "【✗】")))
	local Loc = (mute_location == "Warn") and "【✍🏻】" or ((mute_location == "Kick") and "【🚫】" or ((mute_location == "Mute") and "【🔇】" or ((mute_location == "Enable") and "【✓】" or "【✗】")))
	local Doc = (mute_document == "Warn") and "【✍🏻】" or ((mute_document == "Kick") and "【🚫】" or ((mute_document == "Mute") and "【🔇】" or ((mute_document == "Enable") and "【✓】" or "【✗】")))
	local Voice = (mute_voice == "Warn") and "【✍🏻】" or ((mute_voice == "Kick") and "【🚫】" or ((mute_voice == "Mute") and "【🔇】" or ((mute_voice == "Enable") and "【✓】" or "【✗】")))
	local Audio = (mute_audio == "Warn") and "【✍🏻】" or ((mute_audio == "Kick") and "【🚫】" or ((mute_audio == "Mute") and "【🔇】" or ((mute_audio == "Enable") and "【✓】" or "【✗】")))
	local Video = (mute_video == "Warn") and "【✍🏻】" or ((mute_video == "Kick") and "【🚫】" or ((mute_video == "Mute") and "【🔇】" or ((mute_video == "Enable") and "【✓】" or "【✗】")))
	local VSelf = (mute_video_note == "Warn") and "【✍🏻】" or ((mute_video_note == "Kick") and "【🚫】" or ((mute_video_note == "Mute") and "【🔇】" or ((mute_video_note == "Enable") and "【✓】" or "【✗】")))
	local Tgser =  (mute_tgservice == "Enable" and "【✓】" or "【✗】")
	local All =  (mute_all == "Enable" and "【✓】" or "【✗】")
	text = Source_Start..'*به تنظیمات رسانه گروه خوش آمدید*\n*راهنمای ایموجی :*\n\n✍🏻 = `حالت اخطار`\n🚫 = `حالت اخراج`\n🔇 = `حالت سکوت`\n✓ = `فعال`\n✗ = `غیرفعال`'
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = Source_Start.."همه : "..All, callback_data="muteall:"..Chat_id},
	{text = Source_Start.."گیف : "..Gif, callback_data="mutegif:"..Chat_id}
	},
	{
	{text = Source_Start.."متن : "..Text, callback_data="mutetext:"..Chat_id},
	{text = Source_Start.."اینلاین : "..Inline, callback_data="muteinline:"..Chat_id}
	},
	{
	{text = Source_Start.."بازی : "..Game, callback_data="mutegame:"..Chat_id},
	{text = Source_Start.."عکس : "..Photo, callback_data="mutephoto:"..Chat_id}
	},
	{
	{text = Source_Start.."فیلم : "..Video, callback_data="mutevideo:"..Chat_id},
	{text = Source_Start.."آهنگ : "..Audio, callback_data="muteaudio:"..Chat_id}
	},
	{
	{text = Source_Start.."صدا : "..Voice, callback_data="mutevoice:"..Chat_id},
	{text = Source_Start.."استیکر : "..Sticker, callback_data="mutesticker:"..Chat_id}
	},
	{
	{text = Source_Start.."مخاطب : "..Contact, callback_data="mutecontact:"..Chat_id},
	{text = Source_Start.."کیبورد : "..Key, callback_data="mutekeyboard:"..Chat_id}
	},
	{
	{text = Source_Start.."موقعیت : "..Loc, callback_data="mutelocation:"..Chat_id},
	{text = Source_Start.."فایل : "..Doc, callback_data="mutedocument:"..Chat_id}
	},
	{
	{text = Source_Start.."فوروارد", callback_data="muteforward:"..Chat_id}
	},
	{
	{text = Source_Start.."خدمات تلگرام : "..Tgser, callback_data="mutetgservice:"..Chat_id}
	},
	{
	{text = Source_Start.."فیلم سلفی : "..VSelf, callback_data="mutevideonote:"..Chat_id}
	},
	{
	{text = Source_Start..'بازگشت ', callback_data = 'MenuSettings:'..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function locks(chatid,chatid2, name, Msgid, cb, back, v, st)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	text = Source_Start..'*تنظیمات پیشرفته قفل* `[ '..v..' ]`'
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = ''..name..' : '..st, callback_data = 'Found:'..Chat_id},
	
	},
	{
	{text = Source_Start..'فعال', callback_data = ""..cb.."enable:"..Chat_id},
	{text = Source_Start..'غیر فعال', callback_data = ""..cb.."disable:"..Chat_id}
	},
	{
	{text = Source_Start..'اخطار', callback_data = ""..cb.."warn:"..Chat_id}
	},
	{
	{text = Source_Start..'سکوت', callback_data = ""..cb.."mute:"..Chat_id},
	{text = Source_Start..'اخراج', callback_data = ""..cb.."kick:"..Chat_id}
	},
	{
	{text = Source_Start..'بازگشت', callback_data = back..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function SettingsSpam(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	lock_spam = redis:get(RedisIndex..'lock_spam:'..Chat_id)
	lock_flood = redis:get(RedisIndex..'lock_flood:'..Chat_id)
	local Spam =  (lock_spam == "Enable" and "【✓】" or "【✗】")
	local Flood =  (lock_flood == "Enable" and "【✓】" or "【✗】")
	if redis:get(RedisIndex..Chat_id..'num_msg_max') then
		NUM_MSG_MAX = redis:get(RedisIndex..Chat_id..'num_msg_max')
	else
		NUM_MSG_MAX = 5
	end
	if redis:get(RedisIndex..Chat_id..'set_char') then
		SETCHAR = redis:get(RedisIndex..Chat_id..'set_char')
	else
		SETCHAR = 400
	end
	if redis:get(RedisIndex..Chat_id..'time_check') then
		TIME_CHECK = redis:get(RedisIndex..Chat_id..'time_check')
	else
		TIME_CHECK = 2
	end
	text = Source_Start..'*به تنظیمات آنتی اسپم و فلود گروه خوشآمدید*'..EndMsg
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = Source_Start.."آنتی فلود : "..Flood, callback_data="lockflood:"..Chat_id},
	{text = Source_Start.."آنتی اسپم : "..Spam, callback_data="lockspam:"..Chat_id}
	},
	{
	{text = Source_Start..'حداکثر آنتی فلود', callback_data = 'Found:'..Chat_id}
	},
	{
	{text = "➕", callback_data='floodup:'..Chat_id},
	{text = tostring(NUM_MSG_MAX), callback_data = 'Found:'..Chat_id },
	{text = "➖", callback_data='flooddown:'..Chat_id}
	},
	{
	{text = Source_Start..'حداکثر حروف مجاز', callback_data = 'Found:'..Chat_id}
	},
	{
	{text = "➕", callback_data='charup:'..Chat_id},
	{text = tostring(SETCHAR), callback_data = 'Found:'..Chat_id},
	{text = "➖", callback_data='chardown:'..Chat_id}
	},
	{
	{text = Source_Start..'زمان برسی آنتی اسپم', callback_data = 'Found:'..Chat_id}
	},
	{
	{text = "➕", callback_data='floodtimeup:'..Chat_id},
	{text = tostring(TIME_CHECK), callback_data = 'Found:'..Chat_id},
	{text = "➖", callback_data='floodtimedown:'..Chat_id}
	},
	{
	{text = Source_Start..'بازگشت', callback_data = 'MenuSettings:'..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function SettingsMore(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	text = Source_Start..'`به تنظیمات بیشتر خوشآمدید.`'..EndMsg
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = Source_Start.."قوانین گروه", callback_data="rules:"..Chat_id}
	},
	{
	{text = Source_Start.."لیست مالکین", callback_data="ownerlist:"..Chat_id},
	{text = Source_Start.."لیست مدیران", callback_data="modlist:"..Chat_id}
	},
	{
	{text = Source_Start.."لیست مسدود", callback_data="bans:"..Chat_id},
	{text = Source_Start.."لیست ویژه", callback_data="whitelists:"..Chat_id}
	},
	{
	{text = Source_Start.."لیست فیلتر", callback_data="filterlist:"..Chat_id},
	{text = Source_Start.."لیست سکوت", callback_data="silentlist:"..Chat_id}
	},
	{
	{text = Source_Start.."نمایش پیام خوشامد", callback_data="showwlc:"..Chat_id},
	},
	{
	{text = Source_Start.."بازگشت", callback_data="MenuSettings:"..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function SettingsAdd(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	text = Source_Start..'*به بخش اد اجباری ربات خوشآمدید*'..EndMsg
	local getadd = redis:hget(RedisIndex..'addmemset', Chat_id) or "0"
	local add = redis:hget(RedisIndex..'addmeminv' ,Chat_id)
	local sadd = (add == 'on') and "【✓】" or "【✗】"
	if redis:get(RedisIndex..'addpm'..Chat_id) then
		addpm = "【✗】"
	else
		addpm = "【✓】"
	end
	keyboard = {}
	keyboard.inline_keyboard = {
	{
	{text = Source_Start..'محدودیت اضافه کردن : '..getadd..'', callback_data = 'Found:'..Chat_id}
	},
	{
	{text = '➕', callback_data = 'addlimup:'..Chat_id},
	{text = '➖', callback_data = 'addlimdown:'..Chat_id}
	},
	{
	{text = Source_Start..'وضعیت محدودیت : '..sadd..'', callback_data = 'Found:'..Chat_id}
	},
	{
	{text = '▪️ فعال', callback_data = 'addlimlock:'..Chat_id},
	{text = '▪️ غیرفعال', callback_data = 'addlimunlock:'..Chat_id}
	},
	{
	{text = Source_Start..'ارسال پیام محدودیت : '..addpm..'', callback_data = 'Found:'..Chat_id}
	},
	{
	{text = '▪️ فعال', callback_data = 'addpmon:'..Chat_id},
	{text = '▪️ غیرفعال', callback_data = 'addpmoff:'..Chat_id}
	},
	{
	{text= Source_Start..'بازگشت' ,callback_data = 'MenuSettings:'..Chat_id}
	}
	}
	EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function HelpCode(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	keyboard = {}
	keyboard.inline_keyboard = {
		{
			{text = Source_Start..'راهنمای مدیریتی', callback_data = 'Helpmod:'..Chat_id},
			{text = Source_Start..'راهنمای تنظیمی', callback_data = 'Helpset:'..Chat_id}
		},
		{
			{text = Source_Start..'راهنمای پاکسازی', callback_data = 'Helpclean:'..Chat_id},
			{text = Source_Start..'راهنمای قفلی', callback_data = 'Helplock:'..Chat_id}
		},
		{
			{text= Source_Start..'بستن پنل راهنما' ,callback_data = 'ExitHelp:'..Chat_id}
		}				
	}
	EditInline(chatid, Source_Start..'*به بخش راهنمای ربات خوشآمدید*'..EndMsg..'', chatid2, Msgid, "md", keyboard)
end
function LockHelp(chatid, chatid2 ,Msgid)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	text = Source_Start..'به راهنمای قفلی خوشآمدید'..EndMsg
	keyboard = {} 
	keyboard.inline_keyboard = {
		{
			{text = Source_Start.."قفل خودکار گروه", callback_data="Hauto:"..Chat_id},
		},
		{
			{text = Source_Start.."همه", callback_data="Hall:"..Chat_id},
			{text = Source_Start.."لینک", callback_data="Hlink:"..Chat_id},
			{text = Source_Start.."تبچی", callback_data="Htab:"..Chat_id}
		},
		{
			{text = Source_Start.."فوروارد کانال", callback_data="Hforch:"..Chat_id},
			{text = Source_Start.."فوروارد کاربر", callback_data="Hforus:"..Chat_id}
		},
		{
			{text = Source_Start.."تگ", callback_data="Htag:"..Chat_id},
			{text = Source_Start.."منشن", callback_data="Hman:"..Chat_id},
			{text = Source_Start.."فارسی", callback_data="Hfarsi:"..Chat_id}
		},
		{
			{text = Source_Start.."ویرایش", callback_data="Hedit:"..Chat_id},
			{text = Source_Start.."هرزنامه", callback_data="Hspam:"..Chat_id},
			{text = Source_Start.."پیام مکرر", callback_data="Hflood:"..Chat_id}
		},
		{
			{text = Source_Start.."ربات", callback_data="Hbot:"..Chat_id},
			{text = Source_Start.."فونت", callback_data="Hfont:"..Chat_id},
			{text = Source_Start.."وبسایت", callback_data="Hweb:"..Chat_id}
		},
		{
			{text = Source_Start.."سنجاق", callback_data="Hpin:"..Chat_id},
			{text = Source_Start.."ورود", callback_data="Hjoin:"..Chat_id},
			{text = Source_Start.."گیف", callback_data="Hgif:"..Chat_id}
		},
		{
			{text = Source_Start.."متن", callback_data="Htext:"..Chat_id},
			{text = Source_Start.."عکس", callback_data="Hphoto:"..Chat_id},
			{text = Source_Start.."فیلم", callback_data="Hvideo:"..Chat_id}
		},
		{
			{text = Source_Start.."فیلم سلفی", callback_data="Hself:"..Chat_id},
			{text = Source_Start.."آهنگ", callback_data="Haudio:"..Chat_id},
			{text = Source_Start.."ویس", callback_data="Hvoice:"..Chat_id}
		},
		{
			{text = Source_Start.."استیکر", callback_data="Hsticker:"..Chat_id},
			{text = Source_Start.."مخاطب", callback_data="Hmokha:"..Chat_id},
			{text = Source_Start.."مکان", callback_data="Hloc:"..Chat_id}
		},
		{
			{text = Source_Start.."فایل", callback_data="Hfile:"..Chat_id},
			{text = Source_Start.."سرویس تلگرام", callback_data="Htg:"..Chat_id},
			{text = Source_Start.."دکمه شیشهای", callback_data="Hinline:"..Chat_id}
		},
		{
			{text = Source_Start.."بازی", callback_data="Hgame:"..Chat_id},
			{text = Source_Start.."بازدید", callback_data="Hviewo:"..Chat_id}
		},
		{
			{text = Source_Start.."کیبورد شیشه ای", callback_data="Hkeybord:"..Chat_id}
		},
		{
			{text= Source_Start..'بازگشت' ,callback_data = 'HelpCode:'..Chat_id}
		}				
	}
    EditInline(chatid, text, chatid2, Msgid, "md", keyboard)
end
function LockMsg(chatid, chatid2 ,Msgid, EN, FA)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not chatid2 then
		Chat_id = chatid
	else
		Chat_id = chatid2
	end
	Text = "↬ برای قفل کردن "..FA.." در گروه :\n⫸ `Lock "..EN.."`\n⫸ `قفل "..FA.."`\n\n_○ این دستور برای (حذف) پیام های مکرر که در آن ها "..FA.." به کار رفته است استفاده میشود !_\n✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧\n↬ برای اخطار دادن "..FA.." در گروه :*\n⫸ `Warn "..EN.."`\n⫸ `اخطار "..FA.."`\n\n_○ این دستور برای (اخطار) به کاربرانی که پیام آنها حاوی "..FA.." میباشد است !_\n✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧\n↬ برای اخطار دادن "..FA.." در گروه :*\n⫸ `Mute "..EN.."`\n⫸ `سکوت "..FA.."`\n\n_○ این دستور برای (سکوت) کردن کاربرانی که پیام آنها حاوی "..FA.." میباشد است !_\n✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧\n↬ برای اخطار دادن "..FA.." در گروه :*\n⫸ `Kick "..EN.."`\n⫸ `اخراج "..FA.."`\n\n_○ این دستور برای (اخراج) کردن کاربرانی که پیام آنها حاوی "..FA.." میباشد است !_\n✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧✦✧\n↬ برای آزاد سازی تمامی قفل ها :*\n⫸ `UnLock "..EN.."`\n⫸ `باز کردن "..FA.."`\n\n_○ این دستور برای بازکردن قفل "..FA.."  که کاربران رو محدود میکند استفاده میشود !_"
	keyboard = {} 
	keyboard.inline_keyboard = {{{text= Source_Start..'بازگشت' ,callback_data = 'Helplock:'..Chat_id}}}
	EditInline(chatid, Text, chatid2, Msgid, "md", keyboard)
end
function PanelApi(Msg)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if Msg.text then
		local CmdMatches = Msg.text:lower()
		if CmdMatches:match('^[/#!]') and CmdMatches then
			CmdMatches= CmdMatches:gsub('^[/#!]','')
		end
		if CmdMatches == 'panel' then
			if not redis:get(RedisIndex.."Likes") then
				redis:set(RedisIndex.."Likes", 0)
			end
			if not redis:get(RedisIndex.."DisLikes") then
				redis:set(RedisIndex.."DisLikes", 0)
			end
			local chatid = Msg.chat.id
			local Text = Source_Start..'*به پنل مدیریتی گروه :*\n`[ '..chatid..' ]`\n*خوشآمدید*'..EndMsg..'\n'..Source_Start..'`برای حمایت از ما لطفا در نظر سنجی ربات شرکت کنید` ❤️'
			keyboard = {}
			keyboard.inline_keyboard = {
			{
			{text = "💖 "..tostring(redis:get(RedisIndex.."Likes")), callback_data="Like:"..chatid},
			{text = "💔 "..tostring(redis:get(RedisIndex.."DisLikes")), callback_data="Dislike:"..chatid}
			},
			{
			{text = Source_Start.."تنظیمات قفلی", callback_data="LockSettings:"..chatid},
			{text = Source_Start.."تنظیمات رسانه", callback_data="MuteSettings:"..chatid},
			},
			{
			{text = Source_Start..'آنتی اسپم و فلود', callback_data = 'SpamSettings:'..chatid}
			},
			{
			{text = Source_Start..'اطلاعات گروه', callback_data = 'MoreSettings:'..chatid},
			{text = Source_Start..'اد اجباری', callback_data = 'AddSettings:'..chatid}
			},
			{
			{text = Source_Start..'پشتیبانی ربات', callback_data = 'Manager:'..chatid}
			},
			{
			{text= Source_Start..'بستن پنل گروه' ,callback_data = 'ExitPanel:'..chatid}
			}
			}
			SendInlineApi(Msg.chat.id, Text, keyboard, Msg.message_id, 'md')
		end
	end
end
function PanelCli(Msg)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if Msg.query and Msg.query:sub(1,6) == "Menu:-" and Msg.query:gsub("Menu:-",""):match('%d+') then
		if not redis:get(RedisIndex.."Likes") then
			redis:set(RedisIndex.."Likes", 0)
		end
		if not redis:get(RedisIndex.."DisLikes") then
			redis:set(RedisIndex.."DisLikes", 0)
		end
		local chatid = "-"..Msg.query:match("%d+")
		local Text = Source_Start..'*به پنل مدیریتی گروه :*\n`[ '..chatid..' ]`\n*خوشآمدید*'..EndMsg..'\n'..Source_Start..'`برای حمایت از ما لطفا در نظر سنجی ربات شرکت کنید` ❤️'
		keyboard = {}
		keyboard.inline_keyboard = {
		{
		{text = "💖 "..tostring(redis:get(RedisIndex.."Likes")), callback_data="Like:"..chatid},
		{text = "💔 "..tostring(redis:get(RedisIndex.."DisLikes")), callback_data="Dislike:"..chatid}
		},
		{
		{text = Source_Start.."تنظیمات قفلی", callback_data="LockSettings:"..chatid},
		{text = Source_Start.."تنظیمات رسانه", callback_data="MuteSettings:"..chatid},
		},
		{
		{text = Source_Start..'آنتی اسپم و فلود', callback_data = 'SpamSettings:'..chatid}
		},
		{
		{text = Source_Start..'اطلاعات گروه', callback_data = 'MoreSettings:'..chatid},
		{text = Source_Start..'اد اجباری', callback_data = 'AddSettings:'..chatid}
		},
		{
		{text = Source_Start..'پشتیبانی ربات', callback_data = 'Manager:'..chatid}
		},
		{
		{text= Source_Start..'بستن پنل گروه' ,callback_data = 'ExitPanel:'..chatid}
		}
		}
		SendInlineCli(Msg.id, 'Not OK', 'Group Not Found', chat_id,Text, 'Markdown', keyboard)
	end
	if Msg.query and Msg.query:sub(1,6) == "Help:-" and Msg.query:gsub("Help:-",""):match('%d+') and is_sudo(Msg) then
	local chatid = "-"..Msg.query:match("%d+")
	local Text = Source_Start..'*به بخش راهنمای ربات خوشآمدید*'..EndMsg..''
	keyboard = {}
	keyboard.inline_keyboard = {
		{
			{text = Source_Start..'راهنمای مدیریتی', callback_data = 'Helpmod:'..chatid},
			{text = Source_Start..'راهنمای تنظیمی', callback_data = 'Helpset:'..chatid}
		},
		{
			{text = Source_Start..'راهنمای پاکسازی', callback_data = 'Helpclean:'..chatid},
			{text = Source_Start..'راهنمای قفلی', callback_data = 'Helplock:'..chatid}
		},
		{
			{text= Source_Start..'بستن پنل راهنما' ,callback_data = 'ExitHelp:'..chatid}
		}				
	}
	SendInlineCli(Msg.id, 'Not OK', 'Group Not Found', chat_id,Text, 'Markdown', keyboard)
end
	if Msg.query and Msg.query:sub(1,8) == "Tabchi:-" and Msg.query:gsub("Tabchi:-",""):match('%d+') then
		local chatid = "-"..Msg.query:match("%d+")
		local user_first = redis:get(RedisIndex.."TabchiUsername:"..chatid)
		local user_id = redis:get(RedisIndex.."TabchiUserId:"..chatid)
		user = '['..user_id..'](tg://user?id='..user_id..')'
		redis:set(RedisIndex.."usertabchi:"..chatid..user_id, true)
		local Text = '*کاربر* '..user..' - @'..check_markdown(user_first)..' *شما تبچی شناسای شدهاید باید تایید کنید تبچی تبلیغگر نیستید در غیر این صورت با اخطار بعدی  اخراج خواهید شد*'..EndMsg
		keyboard = {}
		keyboard.inline_keyboard = {
		{{text = '⌯ من تبچی (تبلیغگر) نیستم ⌯',callback_data = 'Tabchi:'..chatid},}
		}
		SendInlineCli(Msg.id, 'Not OK', 'Group Not Found', chat_id,Text, 'Markdown', keyboard)
		redis:del(RedisIndex.."TabchiUsername:"..chatid)
		redis:del(RedisIndex.."TabchiUserId:"..chatid)
	end
	if Msg.query and Msg.query:match("Join") and is_sudo(Msg) then
		keyboard = {}
		keyboard.inline_keyboard = {
		{
		{text = '🏷 کانال ما', url = 'http://t.me/'..channel_inline..''},
		}
		}
		SendInlineCli(Msg.id, 'Not OK', 'Group Not Found', chat_id,'`₪ مدیر گرامی لطفا برای اجرای دستور شما توسط ربات در کانال ما عضو شوید 🌺`', 'Markdown', keyboard)
	end
end
function Modcheck(Msg, Chat, User, First)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not is_mod(Chat, User) then
		ShowMsg(Msg.id, Source_Start..'کاربر '..User..' - '..First..' شما مدیر گروه نمیباشید'..EndMsg..'\nبرای خرید ربات به پیوی :\n '..sudo_username..'\nیا به کانال زیر مراجعه کنید :\n '..channel_username..'', true)
	elseif not is_req(Chat, User) then
		ShowMsg(Msg.id, Source_Start..'کاربر '..User..' - '..First..' شما این فهرست را درخواست نکردید'..EndMsg..'', true)
	else
		return true
	end
end
function Ownercheck(Msg, Chat, User, First)
	local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
	local Source_Start = Emoji[math.random(#Emoji)]
	if not is_owner(Chat, User) then
		ShowMsg(Msg.id, Source_Start..'کاربر '..User..' - '..First..' شما مالک گروه نمیباشید'..EndMsg..'', true)
	elseif not is_req(Chat, User) then
		ShowMsg(Msg.id, Source_Start..'کاربر '..User..' - '..First..' شما این فهرست را درخواست نکردید'..EndMsg..'', true)
	else
		return true
	end
end
--######(( End Function ))######--
function RunHelper()
	while true do
		local updates = getUpdates()
		if updates and updates.result then
			for i = 1, #updates.result do
				local msg = updates.result[i]
				offset = msg.update_id + 1
				if msg.message then
					Msg = msg.message
					if Msg.text then
						PanelApi(Msg)
					end
				end
				if msg.inline_query then
					local Msg = msg.inline_query
					PanelCli(Msg)
				end
				if CmdMatches then
					print(color.blue[1].."[ "..CmdMatches.." ]\n"..color.red[1].."This is "..color.magenta[1].."[ TEXT ]")
				end
				if msg.callback_query then
					local Msg = msg.callback_query
					local Emoji = {"↫ ","⇜ ","⌯ ","↜ "}
					local Source_Start = Emoji[math.random(#Emoji)]
					CmdMatches = Msg.data
					msg.user_first = Msg.from.first_name
					user_first = msg.user_first
					chat_id = '-'..CmdMatches:match('%d+')
					msg.inline_id = Msg.inline_message_id
					user_id = Msg.from.id
					if not msg.inline_id then
						msg_id = Msg.message.message_id
						chat_id = Msg.message.chat.id
						user_id = Msg.from.id
						msg.user_first = Msg.from.first_name
						user_first = msg.user_first
					end
					if CmdMatches == 'Found:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						ShowMsg(Msg.id, Source_Start.."لطفا از دکمه ای دیگری استفاده کنید"..EndMsg, true)
					end
					if CmdMatches == 'Like:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						if redis:get(RedisIndex.."IsDisLiked:"..user_id) then
							redis:del(RedisIndex.."IsDisLiked:"..user_id)
							local dislikes = redis:get(RedisIndex.."DisLikes")
							redis:set(RedisIndex.."DisLikes",dislikes - 1)
							redis:set(RedisIndex.."IsLiked:"..user_id,true)
							local likes = redis:get(RedisIndex.."Likes")
							redis:set(RedisIndex.."Likes",likes + 1)
							ShowMsg(Msg.id, Source_Start.."تشکر فراوان از رای مثبت شما ❤️", true)
						else
							if redis:get(RedisIndex.."IsLiked:"..user_id) then
								redis:del(RedisIndex.."IsLiked:"..user_id)
								local likes = redis:get(RedisIndex.."Likes")
								redis:set(RedisIndex.."Likes",likes - 1)
								ShowMsg(Msg.id, Source_Start.."خیلی بدی مگه چکار کردم رای مثبت رو پس گرفتی 💔", true)
							else
								redis:set(RedisIndex.."IsLiked:"..user_id,true)
								local likes = redis:get(RedisIndex.."Likes")
								redis:set(RedisIndex.."Likes",likes + 1)
								ShowMsg(Msg.id, Source_Start.."تشکر فراوان از رای مثبت شما ❤️", true)
							end
						end
						PanelMenu(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'Dislike:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						if redis:get(RedisIndex.."IsLiked:"..user_id) then
							redis:del(RedisIndex.."IsLiked:"..user_id)
							local likes = redis:get(RedisIndex.."Likes")
							redis:set(RedisIndex.."Likes",likes - 1)
							redis:set(RedisIndex.."IsDisLiked:"..user_id,true)
							local dislikes = redis:get(RedisIndex.."DisLikes")
							redis:set(RedisIndex.."DisLikes",dislikes + 1)
							ShowMsg(Msg.id, Source_Start.."خیلی بدی مگه چیکار کردم رای منفی دادی 💔", true)
						else
							if redis:get(RedisIndex.."IsDisLiked:"..user_id) then
								redis:del(RedisIndex.."IsDisLiked:"..user_id)
								local dislikes = redis:get(RedisIndex.."DisLikes")
								redis:set(RedisIndex.."DisLikes",dislikes - 1)
								ShowMsg(Msg.id, Source_Start.."وای مرسی که رای منفیت رو پس گرفتی 🌹", true)
							else
								redis:set(RedisIndex.."IsDisLiked:"..user_id,true)
								local dislikes = redis:get(RedisIndex.."DisLikes")
								redis:set(RedisIndex.."DisLikes",dislikes + 1)
								ShowMsg(Msg.id, Source_Start.."خیلی بدی مگه چیکار کردم رای منفی دادی 💔", true)
							end
						end
						PanelMenu(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'MenuSettings:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						PanelMenu(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'LockSettings:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						SettingsLock(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'MuteSettings:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						SettingsMute(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'SpamSettings:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'MoreSettings:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						SettingsMore(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'AddSettings:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'locklink:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_link == 'Warn') and "اخطار" or ((lock_link == 'Kick') and "اخراج" or ((lock_link == 'Mute') and "سکوت" or ((lock_link == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل لینک',msg_id,'link','LockSettings:','لینک',st)
					end
					if CmdMatches == 'linkenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_link:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل لینک',msg_id,'link','LockSettings:','لینک',st)
					end
					if CmdMatches == 'linkdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_link:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل لینک',msg_id,'link','LockSettings:','لینک',st)
					end
					if CmdMatches == 'linkwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_link:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل لینک',msg_id,'link','LockSettings:','لینک',st)
					end
					if CmdMatches == 'linkmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_link:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل لینک',msg_id,'link','LockSettings:','لینک',st)
					end
					if CmdMatches == 'linkkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_link:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل لینک',msg_id,'link','LockSettings:','لینک',st)
					end
					if CmdMatches == 'lockviews:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_views == 'Warn') and "اخطار" or ((lock_views == 'Kick') and "اخراج" or ((lock_views == 'Mute') and "سکوت" or ((lock_views == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازدید',msg_id,'views','LockSettings:','بازدید',st)
					end
					if CmdMatches == 'viewsenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_views:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازدید',msg_id,'views','LockSettings:','بازدید',st)
					end
					if CmdMatches == 'viewsdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_views:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازدید',msg_id,'views','LockSettings:','بازدید',st)
					end
					if CmdMatches == 'viewswarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_views:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازدید',msg_id,'views','LockSettings:','بازدید',st)
					end
					if CmdMatches == 'viewsmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_views:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازدید',msg_id,'views','LockSettings:','بازدید',st)
					end
					if CmdMatches == 'viewskick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_views:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازدید',msg_id,'views','LockSettings:','بازدید',st)
					end
					if CmdMatches == 'lockedit:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_edit == 'Warn') and "اخطار" or ((lock_edit == 'Kick') and "اخراج" or ((lock_edit == 'Mute') and "سکوت" or ((lock_edit == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویرایش پیام',msg_id,'edit','LockSettings:','ویرایش پیام',st)
					end
					if CmdMatches == 'editenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_edit:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویرایش پیام',msg_id,'edit','LockSettings:','ویرایش پیام',st)
					end
					if CmdMatches == 'editdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_edit:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویرایش پیام',msg_id,'edit','LockSettings:','ویرایش پیام',st)
					end
					if CmdMatches == 'editwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_edit:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویرایش پیام',msg_id,'edit','LockSettings:','ویرایش پیام',st)
					end
					if CmdMatches == 'editmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_edit:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویرایش پیام',msg_id,'edit','LockSettings:','ویرایش پیام',st)
					end
					if CmdMatches == 'editkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_edit:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویرایش پیام',msg_id,'edit','LockSettings:','ویرایش پیام',st)
					end
					if CmdMatches == 'locktags:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_tag == 'Warn') and "اخطار" or ((lock_tag == 'Kick') and "اخراج" or ((lock_tag == 'Mute') and "سکوت" or ((lock_tag == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل تگ',msg_id,'tag','LockSettings:','تگ',st)
					end
					if CmdMatches == 'tagenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_tag:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل تگ',msg_id,'tag','LockSettings:','تگ',st)
					end
					if CmdMatches == 'tagdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_tag:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل تگ',msg_id,'tag','LockSettings:','تگ',st)
					end
					if CmdMatches == 'tagwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_tag:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل تگ',msg_id,'tag','LockSettings:','تگ',st)
					end
					if CmdMatches == 'tagmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_tag:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل تگ',msg_id,'tag','LockSettings:','تگ',st)
					end
					if CmdMatches == 'tagkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_tag:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل تگ',msg_id,'tag','LockSettings:','تگ',st)
					end
					if CmdMatches == 'lockusernames:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_username == 'Warn') and "اخطار" or ((lock_username == 'Kick') and "اخراج" or ((lock_username == 'Mute') and "سکوت" or ((lock_username == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل نام کاربری',msg_id,'usernames','LockSettings:','نام کاربری',st)
					end
					if CmdMatches == 'usernamesenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_username:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل نام کاربری',msg_id,'usernames','LockSettings:','نام کاربری',st)
					end
					if CmdMatches == 'usernamesdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_username:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل نام کاربری',msg_id,'usernames','LockSettings:','نام کاربری',st)
					end
					if CmdMatches == 'usernameswarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_username:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل نام کاربری',msg_id,'usernames','LockSettings:','نام کاربری',st)
					end
					if CmdMatches == 'usernamesmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_username:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل نام کاربری',msg_id,'usernames','LockSettings:','نام کاربری',st)
					end
					if CmdMatches == 'usernameskick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_username:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل نام کاربری',msg_id,'usernames','LockSettings:','نام کاربری',st)
					end
					if CmdMatches == 'lockmention:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_mention == 'Warn') and "اخطار" or ((lock_mention == 'Kick') and "اخراج" or ((lock_mention == 'Mute') and "سکوت" or ((lock_mention == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'mentionenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_mention:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'mentiondisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_mention:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'mentionkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_mention:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'mentionwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_mention:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'mentionmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_mention:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'mentionkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_mention:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل منشن',msg_id,'mention','LockSettings:','منشن',st)
					end
					if CmdMatches == 'lockarabic:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_arabic == 'Warn') and "اخطار" or ((lock_arabic == 'Kick') and "اخراج" or ((lock_arabic == 'Mute') and "سکوت" or ((lock_arabic == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل فارسی',msg_id,'farsi','LockSettings:','فارسی',st)
					end
					if CmdMatches == 'farsienable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_arabic:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فارسی',msg_id,'farsi','LockSettings:','فارسی',st)
					end
					if CmdMatches == 'farsidisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_arabic:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فارسی',msg_id,'farsi','LockSettings:','فارسی',st)
					end
					if CmdMatches == 'farsiwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_arabic:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فارسی',msg_id,'farsi','LockSettings:','فارسی',st)
					end
					if CmdMatches == 'farsimute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_arabic:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فارسی',msg_id,'farsi','LockSettings:','فارسی',st)
					end
					if CmdMatches == 'farsikick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_arabic:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فارسی',msg_id,'farsi','LockSettings:','فارسی',st)
					end
					if CmdMatches == 'lockwebpage:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_webpage == 'Warn') and "اخطار" or ((lock_webpage == 'Kick') and "اخراج" or ((lock_webpage == 'Mute') and "سکوت" or ((lock_webpage == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل وبسایت',msg_id,'web','LockSettings:','وبسایت',st)
					end
					if CmdMatches == 'webenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_webpage:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل وبسایت',msg_id,'web','LockSettings:','وبسایت',st)
					end
					if CmdMatches == 'webdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_webpage:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل وبسایت',msg_id,'web','LockSettings:','وبسایت',st)
					end
					if CmdMatches == 'webwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_webpage:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل وبسایت',msg_id,'web','LockSettings:','وبسایت',st)
					end
					if CmdMatches == 'webmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_webpage:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل وبسایت',msg_id,'web','LockSettings:','وبسایت',st)
					end
					if CmdMatches == 'webkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_webpage:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل وبسایت',msg_id,'web','LockSettings:','وبسایت',st)
					end
					if CmdMatches == 'lockmarkdown:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (lock_markdown == 'Warn') and "اخطار" or ((lock_markdown == 'Kick') and "اخراج" or ((lock_markdown == 'Mute') and "سکوت" or ((lock_markdown == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل فونت',msg_id,'markdown','LockSettings:','فونت',st)
					end
					if CmdMatches == 'markdownenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_markdown:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فونت',msg_id,'markdown','LockSettings:','فونت',st)
					end
					if CmdMatches == 'markdowndisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_markdown:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فونت',msg_id,'markdown','LockSettings:','فونت',st)
					end
					if CmdMatches == 'markdownwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_markdown:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فونت',msg_id,'markdown','LockSettings:','فونت',st)
					end
					if CmdMatches == 'markdownmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_markdown:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فونت',msg_id,'markdown','LockSettings:','فونت',st)
					end
					if CmdMatches == 'markdownkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_markdown:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فونت',msg_id,'markdown','LockSettings:','فونت',st)
					end
					if CmdMatches == 'mutevideonote:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_video_note == 'Warn') and "اخطار" or ((mute_video_note == 'Kick') and "اخراج" or ((mute_video_note == 'Mute') and "سکوت" or ((mute_video_note == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم سلفی',msg_id,'note','MuteSettings:','فیلم سلفی',st)
					end
					if CmdMatches == 'noteenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video_note:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم سلفی',msg_id,'note','MuteSettings:','فیلم سلفی',st)
					end
					if CmdMatches == 'notedisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_video_note:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم سلفی',msg_id,'note','MuteSettings:','فیلم سلفی',st)
					end
					if CmdMatches == 'notewarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video_note:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم سلفی',msg_id,'note','MuteSettings:','فیلم سلفی',st)
					end
					if CmdMatches == 'notemute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video_note:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم سلفی',msg_id,'note','MuteSettings:','فیلم سلفی',st)
					end
					if CmdMatches == 'notekick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video_note:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم سلفی',msg_id,'note','MuteSettings:','فیلم سلفی',st)
					end
					if CmdMatches == 'mutegif:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_gif == 'Warn') and "اخطار" or ((mute_gif == 'Kick') and "اخراج" or ((mute_gif == 'Mute') and "سکوت" or ((mute_gif == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل گیف',msg_id,'gif','MuteSettings:','گیف',st)
					end
					if CmdMatches == 'gifenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_gif:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل گیف',msg_id,'gif','MuteSettings:','گیف',st)
					end
					if CmdMatches == 'gifdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_gif:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل گیف',msg_id,'gif','MuteSettings:','گیف',st)
					end
					if CmdMatches == 'gifwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_gif:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل گیف',msg_id,'gif','MuteSettings:','گیف',st)
					end
					if CmdMatches == 'gifmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_gif:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل گیف',msg_id,'gif','MuteSettings:','گیف',st)
					end
					if CmdMatches == 'gifkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_gif:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل گیف',msg_id,'gif','MuteSettings:','گیف',st)
					end
					if CmdMatches == 'mutetext:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_text == 'Warn') and "اخطار" or ((mute_text == 'Kick') and "اخراج" or ((mute_text == 'Mute') and "سکوت" or ((mute_text == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل متن',msg_id,'text','MuteSettings:','متن',st)
					end
					if CmdMatches == 'textenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_text:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل متن',msg_id,'text','MuteSettings:','متن',st)
					end
					if CmdMatches == 'textdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_text:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل متن',msg_id,'text','MuteSettings:','متن',st)
					end
					if CmdMatches == 'textwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_text:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل متن',msg_id,'text','MuteSettings:','متن',st)
					end
					if CmdMatches == 'textmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_text:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل متن',msg_id,'text','MuteSettings:','متن',st)
					end
					if CmdMatches == 'textkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_text:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل متن',msg_id,'text','MuteSettings:','متن',st)
					end
					if CmdMatches == 'muteinline:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_inline == 'Warn') and "اخطار" or ((mute_inline == 'Kick') and "اخراج" or ((mute_inline == 'Mute') and "سکوت" or ((mute_inline == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل دکمه شیشه ای',msg_id,'inline','MuteSettings:','دکمه شیشه ای',st)
					end
					if CmdMatches == 'inlineenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_inline:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل دکمه شیشه ای',msg_id,'inline','MuteSettings:','دکمه شیشه ای',st)
					end
					if CmdMatches == 'inlinedisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_inline:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل دکمه شیشه ای',msg_id,'inline','MuteSettings:','دکمه شیشه ای',st)
					end
					if CmdMatches == 'inlinewarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_inline:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل دکمه شیشه ای',msg_id,'inline','MuteSettings:','دکمه شیشه ای',st)
					end
					if CmdMatches == 'inlinemute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_inline:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل دکمه شیشه ای',msg_id,'inline','MuteSettings:','دکمه شیشه ای',st)
					end
					if CmdMatches == 'inlinekick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_inline:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل دکمه شیشه ای',msg_id,'inline','MuteSettings:','دکمه شیشه ای',st)
					end
					if CmdMatches == 'mutegame:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_game == 'Warn') and "اخطار" or ((mute_game == 'Kick') and "اخراج" or ((mute_game == 'Mute') and "سکوت" or ((mute_game == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازی',msg_id,'game','MuteSettings:','بازی',st)
					end
					if CmdMatches == 'gameenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_game:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازی',msg_id,'game','MuteSettings:','بازی',st)
					end
					if CmdMatches == 'gamedisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_game:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازی',msg_id,'game','MuteSettings:','بازی',st)
					end
					if CmdMatches == 'gamewarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_game:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازی',msg_id,'game','MuteSettings:','بازی',st)
					end
					if CmdMatches == 'gamemute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_game:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازی',msg_id,'game','MuteSettings:','بازی',st)
					end
					if CmdMatches == 'gamekick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_game:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل بازی',msg_id,'game','MuteSettings:','بازی',st)
					end
					if CmdMatches == 'mutephoto:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_photo == 'Warn') and "اخطار" or ((mute_photo == 'Kick') and "اخراج" or ((mute_photo == 'Mute') and "سکوت" or ((mute_photo == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل عکس',msg_id,'photo','MuteSettings:','عکس',st)
					end
					if CmdMatches == 'photoenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_photo:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل عکس',msg_id,'photo','MuteSettings:','عکس',st)
					end
					if CmdMatches == 'photodisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_photo:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل عکس',msg_id,'photo','MuteSettings:','عکس',st)
					end
					if CmdMatches == 'photowarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_photo:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل عکس',msg_id,'photo','MuteSettings:','عکس',st)
					end
					if CmdMatches == 'photomute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_photo:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل عکس',msg_id,'photo','MuteSettings:','عکس',st)
					end
					if CmdMatches == 'photokick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_photo:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل عکس',msg_id,'photo','MuteSettings:','عکس',st)
					end
					if CmdMatches == 'mutevideo:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_video == 'Warn') and "اخطار" or ((mute_video == 'Kick') and "اخراج" or ((mute_video == 'Mute') and "سکوت" or ((mute_video == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم',msg_id,'video','MuteSettings:','فیلم',st)
					end
					if CmdMatches == 'videoenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم',msg_id,'video','MuteSettings:','فیلم',st)
					end
					if CmdMatches == 'videodisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_video:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم',msg_id,'video','MuteSettings:','فیلم',st)
					end
					if CmdMatches == 'videowarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم',msg_id,'video','MuteSettings:','فیلم',st)
					end
					if CmdMatches == 'videomute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم',msg_id,'video','MuteSettings:','فیلم',st)
					end
					if CmdMatches == 'videokick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_video:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل فیلم',msg_id,'video','MuteSettings:','فیلم',st)
					end
					if CmdMatches == 'muteaudio:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_audio == 'Warn') and "اخطار" or ((mute_audio == 'Kick') and "اخراج" or ((mute_audio == 'Mute') and "سکوت" or ((mute_audio == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل آهنگ',msg_id,'audio','MuteSettings:','آهنگ',st)
					end
					if CmdMatches == 'audioenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_audio:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل آهنگ',msg_id,'audio','MuteSettings:','آهنگ',st)
					end
					if CmdMatches == 'audiodisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_audio:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل آهنگ',msg_id,'audio','MuteSettings:','آهنگ',st)
					end
					if CmdMatches == 'audiowarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_audio:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل آهنگ',msg_id,'audio','MuteSettings:','آهنگ',st)
					end
					if CmdMatches == 'audiomute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_audio:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل آهنگ',msg_id,'audio','MuteSettings:','آهنگ',st)
					end
					if CmdMatches == 'audiokick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_audio:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل آهنگ',msg_id,'audio','MuteSettings:','آهنگ',st)
					end
					if CmdMatches == 'mutevoice:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_voice == 'Warn') and "اخطار" or ((mute_voice == 'Kick') and "اخراج" or ((mute_voice == 'Mute') and "سکوت" or ((mute_voice == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویس',msg_id,'voice','MuteSettings:','ویس',st)
					end
					if CmdMatches == 'voiceenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_voice:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویس',msg_id,'voice','MuteSettings:','ویس',st)
					end
					if CmdMatches == 'voicedisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_voice:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویس',msg_id,'voice','MuteSettings:','ویس',st)
					end
					if CmdMatches == 'voicewarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_voice:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویس',msg_id,'voice','MuteSettings:','ویس',st)
					end
					if CmdMatches == 'voicemute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_voice:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویس',msg_id,'voice','MuteSettings:','ویس',st)
					end
					if CmdMatches == 'voicekick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_voice:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل ویس',msg_id,'voice','MuteSettings:','ویس',st)
					end
					if CmdMatches == 'mutesticker:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_sticker == 'Warn') and "اخطار" or ((mute_sticker == 'Kick') and "اخراج" or ((mute_sticker == 'Mute') and "سکوت" or ((mute_sticker == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل استیکر',msg_id,'sticker','MuteSettings:','استیکر',st)
					end
					if CmdMatches == 'stickerenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_sticker:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل استیکر',msg_id,'sticker','MuteSettings:','استیکر',st)
					end
					if CmdMatches == 'stickerdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_sticker:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل استیکر',msg_id,'sticker','MuteSettings:','استیکر',st)
					end
					if CmdMatches == 'stickerwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_sticker:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل استیکر',msg_id,'sticker','MuteSettings:','استیکر',st)
					end
					if CmdMatches == 'stickermute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_sticker:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل استیکر',msg_id,'sticker','MuteSettings:','استیکر',st)
					end
					if CmdMatches == 'stickerkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_sticker:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل استیکر',msg_id,'sticker','MuteSettings:','استیکر',st)
					end
					if CmdMatches == 'mutecontact:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_contact == 'Warn') and "اخطار" or ((mute_contact == 'Kick') and "اخراج" or ((mute_contact == 'Mute') and "سکوت" or ((mute_contact == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,Source_Start..'قفل مخاطب',msg_id,'contact','MuteSettings:','مخاطب',st)
					end
					if CmdMatches == 'contactenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_contact:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل مخاطب',msg_id,'contact','MuteSettings:','مخاطب',st)
					end
					if CmdMatches == 'contactdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_contact:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,Source_Start..'قفل مخاطب',msg_id,'contact','MuteSettings:','مخاطب',st)
					end
					if CmdMatches == 'contactwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_contact:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,Source_Start..'قفل مخاطب',msg_id,'contact','MuteSettings:','مخاطب',st)
					end
					if CmdMatches == 'contactmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_contact:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,Source_Start..'قفل مخاطب',msg_id,'contact','MuteSettings:','مخاطب',st)
					end
					if CmdMatches == 'contactkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_contact:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,Source_Start..'قفل مخاطب',msg_id,'contact','MuteSettings:','مخاطب',st)
					end
					if CmdMatches == 'muteforward:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						if not chat_id then
							Chat_id = msg.inline_id
						else
							Chat_id = chat_id
						end
						mute_forwardch = redis:get(RedisIndex..'mute_forward:'..Chat_id)
						mute_forwarduser = redis:get(RedisIndex..'mute_forwarduser:'..Chat_id)
						local FwdCh = (mute_forwardch == "Warn") and "【✍🏻】" or ((mute_forwardch == "Kick") and "【🚫】" or ((mute_forwardch == "Mute") and "【🔇】" or ((mute_forwardch == "Enable") and "【✓】" or "【✗】")))
						local FwdUser = (mute_forwarduser == "Warn") and "【✍🏻】" or ((mute_forwarduser == "Kick") and "【🚫】" or ((mute_forwarduser == "Mute") and "【🔇】" or ((mute_forwarduser == "Enable") and "【✓】" or "【✗】")))
						text = Source_Start..'*به تنظیمات قفل فوروارد خوش آمدید*\n*راهنمای ایموجی :*\n\n✍🏻 = `حالت اخطار`\n🚫 = `حالت اخراج`\n🔇 = `حالت سکوت`\n✓ = `فعال`\n✗ = `غیرفعال`'
						keyboard = {}
						keyboard.inline_keyboard = {
						{{text = Source_Start.."فوروارد کانال :"..FwdCh, callback_data="muteforwardch:"..Chat_id}},
						{{text = Source_Start.."فوروارد کاربر :"..FwdUser, callback_data="muteforwarduser:"..Chat_id}},
						{{text = Source_Start.."بازگشت", callback_data="MuteSettings:"..Chat_id}}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md", keyboard)
					end
					if CmdMatches == 'muteforwardch:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_forwardch == 'Warn') and "اخطار" or ((mute_forwardch == 'Kick') and "اخراج" or ((mute_forwardch == 'Mute') and "سکوت" or ((mute_forwardch == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کانال',msg_id,'fwd','muteforward:','فوروارد کانال',st)
					end
					if CmdMatches == 'muteforwarduser:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_forwarduser == 'Warn') and "اخطار" or ((mute_forwarduser == 'Kick') and "اخراج" or ((mute_forwarduser == 'Mute') and "سکوت" or ((mute_forwarduser == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کاربر',msg_id,'fwduser','muteforward:','فوروارد کاربر',st)
					end
					if CmdMatches == 'fwdenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forward:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کانال',msg_id,'fwd','muteforward:','فوروارد کانال',st)
					end
					if CmdMatches == 'fwddisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_forward:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کانال',msg_id,'fwd','muteforward:','فوروارد کانال',st)
					end
					if CmdMatches == 'fwdwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forward:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کانال',msg_id,'fwd','muteforward:','فوروارد کانال',st)
					end
					if CmdMatches == 'fwdmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forward:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کانال',msg_id,'fwd','muteforward:','فوروارد کانال',st)
					end
					if CmdMatches == 'fwdkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forwarduser:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کانال',msg_id,'fwd','muteforward:','فوروارد کانال',st)
					end
					if CmdMatches == 'fwduserenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forwarduser:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کاربر',msg_id,'fwduser','muteforward:','فوروارد کاربر',st)
					end
					if CmdMatches == 'fwduserdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_forwarduser:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کاربر',msg_id,'fwduser','muteforward:','فوروارد کاربر',st)
					end
					if CmdMatches == 'fwduserwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forwarduser:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کاربر',msg_id,'fwduser','muteforward:','فوروارد کاربر',st)
					end
					if CmdMatches == 'fwdusermute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forwarduser:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کاربر',msg_id,'fwduser','muteforward:','فوروارد کاربر',st)
					end
					if CmdMatches == 'fwduserkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_forwarduser:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,'⇜ قفل فوروارد کاربر',msg_id,'fwduser','muteforward:','فوروارد کاربر',st)
					end
					if CmdMatches == 'mutelocation:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_location == 'Warn') and "اخطار" or ((mute_location == 'Kick') and "اخراج" or ((mute_location == 'Mute') and "سکوت" or ((mute_location == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,'⇜ قفل مکان',msg_id,'location','MuteSettings:','مکان',st)
					end
					if CmdMatches == 'locationenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_location:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,'⇜ قفل مکان',msg_id,'location','MuteSettings:','مکان',st)
					end
					if CmdMatches == 'locationdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_location:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,'⇜ قفل مکان',msg_id,'location','MuteSettings:','مکان',st)
					end
					if CmdMatches == 'locationwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_location:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,'⇜ قفل مکان',msg_id,'location','MuteSettings:','مکان',st)
					end
					if CmdMatches == 'locationmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_location:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,'⇜ قفل مکان',msg_id,'location','MuteSettings:','مکان',st)
					end
					if CmdMatches == 'locationkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_location:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,'⇜ قفل مکان',msg_id,'location','MuteSettings:','مکان',st)
					end
					if CmdMatches == 'mutedocument:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_document == 'Warn') and "اخطار" or ((mute_document == 'Kick') and "اخراج" or ((mute_document == 'Mute') and "سکوت" or ((mute_document == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,'⇜ قفل فایل',msg_id,'document','MuteSettings:','فایل',st)
					end
					if CmdMatches == 'documentenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_document:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,'⇜ قفل فایل',msg_id,'document','MuteSettings:','فایل',st)
					end
					if CmdMatches == 'documentdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_document:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,'⇜ قفل فایل',msg_id,'document','MuteSettings:','فایل',st)
					end
					if CmdMatches == 'documentwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_document:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,'⇜ قفل فایل',msg_id,'document','MuteSettings:','فایل',st)
					end
					if CmdMatches == 'documentmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_document:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,'⇜ قفل فایل',msg_id,'document','MuteSettings:','فایل',st)
					end
					if CmdMatches == 'documentkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_document:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,'⇜ قفل فایل',msg_id,'document','MuteSettings:','فایل',st)
					end
					if CmdMatches == 'mutekeyboard:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local st = (mute_keyboard == 'Warn') and "اخطار" or ((mute_keyboard == 'Kick') and "اخراج" or ((mute_keyboard == 'Mute') and "سکوت" or ((mute_keyboard == 'Enable') and "فعال" or "غیرفعال")))
						locks(msg.inline_id,chat_id,'⇜ قفل کیبورد شیشه ای',msg_id,'keyboard','MuteSettings:','کیبورد شیشه ای',st)
					end
					if CmdMatches == 'keyboardenable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_keyboard:'..chat_id, 'Enable')
						local st = "فعال"
						locks(msg.inline_id,chat_id,'⇜ قفل کیبورد شیشه ای',msg_id,'keyboard','MuteSettings:','کیبورد شیشه ای',st)
					end
					if CmdMatches == 'keyboarddisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'mute_keyboard:'..chat_id)
						local st = "غیرفعال"
						locks(msg.inline_id,chat_id,'⇜ قفل کیبورد شیشه ای',msg_id,'keyboard','MuteSettings:','کیبورد شیشه ای',st)
					end
					if CmdMatches == 'keyboardwarn:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_keyboard:'..chat_id, 'Warn')
						local st = "اخطار"
						locks(msg.inline_id,chat_id,'⇜ قفل کیبورد شیشه ای',msg_id,'keyboard','MuteSettings:','کیبورد شیشه ای',st)
					end
					if CmdMatches == 'keyboardmute:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_keyboard:'..chat_id, 'Mute')
						local st = "سکوت"
						locks(msg.inline_id,chat_id,'⇜ قفل کیبورد شیشه ای',msg_id,'keyboard','MuteSettings:','کیبورد شیشه ای',st)
					end
					if CmdMatches == 'keyboardkick:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'mute_keyboard:'..chat_id, 'Kick')
						local st = "اخراج"
						locks(msg.inline_id,chat_id,'⇜ قفل کیبورد شیشه ای',msg_id,'keyboard','MuteSettings:','کیبورد شیشه ای',st)
					end
					if CmdMatches == 'lockjoin:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chklock = redis:get(RedisIndex..'lock_join:'..chat_id)
						if chklock then
							text = 'قفل ورود غیرفعال شد'
							redis:del(RedisIndex..'lock_join:'..chat_id)
						else
							text = 'قفل ورود فعال شد'
							redis:set(RedisIndex..'lock_join:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsLock(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'lockflood:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chklock = redis:get(RedisIndex..'lock_flood:'..chat_id)
						if chklock then
							text = 'قفل پیام های مکرر غیرفعال شد'
							redis:del(RedisIndex..'lock_flood:'..chat_id)
						else
							text = 'قفل پیام های مکرر فعال شد'
							redis:set(RedisIndex..'lock_flood:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'lockspam:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chklock = redis:get(RedisIndex..'lock_spam:'..chat_id)
						if chklock then
							text = 'قفل هرزنامه غیرفعال شد'
							redis:del(RedisIndex..'lock_spam:'..chat_id)
						else
							text = 'قفل هرزنامه فعال شد'
							redis:set(RedisIndex..'lock_spam:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'lockpin:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chklock = redis:get(RedisIndex..'lock_pin:'..chat_id)
						if chklock then
							text = 'قفل سنجاق کردن غیرفعال شد'
							redis:del(RedisIndex..'lock_pin:'..chat_id)
						else
							text = 'قفل سنجاق کردن فعال شد'
							redis:set(RedisIndex..'lock_pin:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsLock(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'lockbots:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						lock_bots = redis:get(RedisIndex..'lock_bots:'..chat_id)
						Bot = (lock_bots == "Pro") and "اخراج کاربر و ربات" or ((lock_bots == "Enable") and "اخراج ربات" or "غیرفعال")
						SettingsBots(msg.inline_id, chat_id, msg_id ,Bot)
					end
					if CmdMatches == 'lockbotskickbot:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_bots:'..chat_id, 'Enable')
						SettingsBots(msg.inline_id, chat_id, msg_id, "اخراج ربات")
					end
					if CmdMatches == 'lockbotsdisable:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'lock_bots:'..chat_id)
						SettingsBots(msg.inline_id, chat_id, msg_id, "غیرفعال")
					end
					if CmdMatches == 'lockbotskickuser:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'lock_bots:'..chat_id, 'Pro')
						SettingsBots(msg.inline_id, chat_id, msg_id, "اخراج ربات و کاربر")
					end
					if CmdMatches == 'welcomel:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chklock = redis:get(RedisIndex..'welcome:'..chat_id)
						if chklock then
							text = 'خوش آمد گویی غیرفعال شد'
							redis:del(RedisIndex..'welcome:'..chat_id)
						else
							text = 'خوش آمد گویی فعال شد'
							redis:set(RedisIndex..'welcome:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsLock(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'muteall:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chkmute = redis:get(RedisIndex..'mute_all:'..chat_id)
						if chkmute then
							text = 'بیصدا کردن همه غیرفعال شد'
							redis:del(RedisIndex..'mute_all:'..chat_id)
						else
							text = 'بیصدا کردن همه فعال شد'
							redis:set(RedisIndex..'mute_all:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsMute(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'mutetgservice:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chkmute = redis:get(RedisIndex..'mute_tgservice:'..chat_id)
						if chkmute then
							text = 'بیصدا کردن خدمات تلگرام غیرفعال شد'
							redis:del(RedisIndex..'mute_tgservice:'..chat_id)
						else
							text = 'بیصدا کردن خدمات تلگرام فعال شد'
							redis:set(RedisIndex..'mute_tgservice:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsMute(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'locktabchi:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local chkmute = redis:get(RedisIndex..'lock_tabchi:'..chat_id)
						if chkmute then
							text = 'قفل تبچی غیرفعال شد'
							redis:del(RedisIndex..'lock_tabchi:'..chat_id)
						else
							text = 'قفل تبچی فعال شد'
							redis:set(RedisIndex..'lock_tabchi:'..chat_id, 'Enable')
						end
						ShowMsg(Msg.id, Source_Start..text..EndMsg, true)
						SettingsLock(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'floodup:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local flood_max = redis:get(RedisIndex..chat_id..'num_msg_max') or 5
						if tonumber(flood_max) < 30 then
							flood_max = tonumber(flood_max) + 1
							redis:set(RedisIndex..chat_id..'num_msg_max', flood_max)
							text = "حساسیت پیام های مکرر تنظیم شد به : "..flood_max
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'flooddown:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local flood_max = redis:get(RedisIndex..chat_id..'num_msg_max') or 5
						if tonumber(flood_max) > 2 then
							flood_max = tonumber(flood_max) - 1
							redis:set(RedisIndex..chat_id..'num_msg_max', flood_max)
							text = "حساسیت پیام های مکرر تنظیم شد به : "..flood_max
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'charup:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local char_max = redis:get(RedisIndex..chat_id..'set_char') or 400
						if tonumber(char_max) < 4000 then
							char_max = tonumber(char_max) + 100
							redis:set(RedisIndex..chat_id..'set_char', char_max)
							text = "تعداد حروف مجاز تنظیم شد به : "..char_max
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'chardown:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local char_max = redis:get(RedisIndex..chat_id..'set_char') or 400
						if tonumber(char_max) > 100 then
							char_max = tonumber(char_max) - 100
							redis:set(RedisIndex..chat_id..'set_char', char_max)
							text = "تعداد حروف مجاز تنظیم شد به : "..char_max
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'floodtimeup:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local check_time = redis:get(RedisIndex..chat_id..'time_check') or 2
						if tonumber(check_time) < 10 then
							check_time = tonumber(check_time) + 1
							redis:set(RedisIndex..chat_id..'time_check', check_time)
							text = "زمان بررسی پیام های مکرر تنظیم شد به : "..check_time
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'floodtimedown:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local check_time = 2
						if tonumber(check_time) > 2 then
							check_time = tonumber(check_time) - 1
							redis:set(RedisIndex..chat_id..'time_check', check_time)
							text = "زمان بررسی پیام های مکرر تنظیم شد به : "..check_time
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsSpam(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'addlimup:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						getadd = redis:hget(RedisIndex..'addmemset', chat_id) or "1"
						if tonumber(getadd) < 10 then
							redis:hset(RedisIndex..'addmemset', chat_id, getadd + 1)
							text = "تنظیم محدودیت اضافه کردن کاربر به : "..getadd
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'addlimdown:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						getadd = redis:hget(RedisIndex..'addmemset', chat_id) or "1"
						if tonumber(getadd) > 1 then
							redis:hset(RedisIndex..'addmemset', chat_id, getadd - 1)
							text = "تنظیم محدودیت اضافه کردن کاربر به : "..getadd
							ShowMsg(Msg.id, Source_Start..text, true)
						end
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'addlimlock:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:hset(RedisIndex..'addmeminv', chat_id, 'on')
						ShowMsg(Msg.id, Source_Start.."محدودیت اضافه کردن کاربر #فعال شد"..EndMsg, true)
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'addlimunlock:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:hset(RedisIndex..'addmeminv', chat_id, 'off')
						ShowMsg(Msg.id, Source_Start.."محدودیت اضافه کردن کاربر #غیرفعال شد"..EndMsg, true)
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'addpmon:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:del(RedisIndex..'addpm'..chat_id)
						ShowMsg(Msg.id, Source_Start.."ارسال پیام محدودیت کاربر #فعال شد"..EndMsg, true)
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'addpmoff:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						redis:set(RedisIndex..'addpm'..chat_id, true)
						ShowMsg(Msg.id, Source_Start.."ارسال پیام محدودیت کاربر #غیرفعال شد"..EndMsg, true)
						SettingsAdd(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'ownerlist:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex..'Owners:'..chat_id)
						text = Source_Start..'*لیست مالکین گروه :*\n'
						for k,v in pairs(list) do
							local user_name = redis:get(RedisIndex..'user_name:'..v)
							text = text..k.."- `" ..v.. "` - "..check_markdown(user_name).."\n"
						end
						if #list == 0 then
							text = Source_Start.."`در حال حاضر هیچ مالکی برای گروه انتخاب نشده است`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."برکناری تمام مالکین", callback_data="cleanowners:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'modlist:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex..'Mods:'..chat_id)
						text = Source_Start..'*لیست مدیران گروه :*\n'
						for k,v in pairs(list) do
							local user_name = redis:get(RedisIndex..'user_name:'..v)
							text = text..k.."- `" ..v.. "` - "..check_markdown(user_name).."\n"
						end
						if #list == 0 then
							text = Source_Start.."`در حال حاضر هیچ مدیری برای گروه انتخاب نشده است`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."برکناری تمام مدیران", callback_data="cleanmods:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'silentlist:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex..'Silentlist:'..chat_id)
						text = Source_Start..'*لیست سکوت گروه :*\n'
						for k,v in pairs(list) do
							local user_name = redis:get(RedisIndex..'user_name:'..v)
							text = text..k.."- `" ..v.. "` - "..check_markdown(user_name).."\n"
						end
						if #list == 0 then
							text = Source_Start.."`در حال حاضر هیچ کاربری در لیست سکوت گروه وجود ندارد`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'bans:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex.."Banned:"..chat_id)
						text = Source_Start..'*لیست کاربران محروم شده از گروه :*\n'
						for k,v in pairs(list) do
							local user_name = redis:get(RedisIndex..'user_name:'..v)
							text = text..k.."- `" ..v.. "` - "..check_markdown(user_name).."\n"
						end
						if #list == 0 then
							text = Source_Start.."*هیچ کاربری از این گروه محروم نشده*"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."پاک کردن لیست مسدود ", callback_data="cleanbans:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'whitelists:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex.."Whitelist:"..chat_id)
						text = Source_Start..'`کاربران لیست ویژه :`\n'
						for k,v in pairs(list) do
							local user_name = redis:get(RedisIndex..'user_name:'..v)
							text = text..k.."- `" ..v.. "` - "..check_markdown(user_name).."\n"
						end
						if #list == 0 then
							text = Source_Start.."*هیچ کاربری در لیست ویژه وجود ندارد*"..EndMsg
						end
						local keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."حذف لیست ویژه", callback_data="cleanwhitelists:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'filterlist:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local names = redis:hkeys(RedisIndex..'filterlist:'..chat_id)
						text = Source_Start..'`لیست کلمات فیلتر شده :`\n'
						local b = 1
						for i = 1, #names do
							text = text .. b .. ". " .. names[i] .. "\n"
							b = b + 1
						end
						if #names == 0 then
							text = Source_Start.."`لیست کلمات فیلتر شده خالی است`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."پاک کردن", callback_data="cleanfilterlist:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'rules:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local rules = redis:get(RedisIndex..chat_id..'rules')
						if not rules then
							text = Source_Start.."قوانین ثبت نشده است"..EndMsg
						elseif rules then
							text = Source_Start..'قوانین گروه :\n'..rules
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."پاک کردن", callback_data="cleanrules:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'showwlc:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						local wlc = redis:get(RedisIndex..'welcome:'..chat_id)
						if not wlc then
							text = Source_Start.."پیام خوشامد تنظیم نشده است"..EndMsg
						else
							text = Source_Start..'پیام خوشامد:\n'..wlc
						end
						local keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."حذف پیام خوشامد", callback_data="cleanwlcmsg:"..chat_id}
						},
						{
						{text = Source_Start.."بازگشت", callback_data="MoreSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanowners:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex..'Owners:'..chat_id)
						if #list == 0 then
							text = Source_Start.."`مالکی برای گروه انتخاب نشده است`"..EndMsg
						else
							redis:del(RedisIndex.."Owners:"..chat_id)
							text = Source_Start.."`تمامی مالکان گروه تنزیل مقام شدند`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="ownerlist:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanmods:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex..'Mods:'..chat_id)
						if #list == 0 then
							text = Source_Start.."هیچ مدیری برای گروه انتخاب نشده است"..EndMsg
						else
							redis:del(RedisIndex.."Mods:"..chat_id)
							text = Source_Start.."`تمام مدیران گروه تنزیل مقام شدند`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="modlist:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanbans:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						local list = redis:smembers(RedisIndex..'Banned:'..chat_id)
						if #list == 0 then
							text = Source_Start.."*هیچ کاربری از این گروه محروم نشده*"..EndMsg
						else
							redis:del(RedisIndex.."Banned:"..chat_id)
							text = Source_Start.."*تمام کاربران محروم شده از گروه از محرومیت خارج شدند*"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="bans:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanwhitelists:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						if redis:get(RedisIndex.."Whitelist:"..chat_id) then
							text = Source_Start.."لیست ویژه خالی می باشد"..EndMsg
						else
							text = Source_Start.."لیست ویژه حذف شد"..EndMsg
							redis:del(RedisIndex.."Whitelist:"..chat_id)
						end
						local keyboard = {}
						keyboard.inline_keyboard = {
						
						{
						{text = Source_Start.."بازگشت", callback_data="whitelists:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanfilterlist:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						local names = redis:hkeys(RedisIndex..'filterlist:'..chat_id)
						if #names == 0 then
							text = Source_Start.."`لیست کلمات فیلتر شده خالی است`"..EndMsg
						else
							redis:del(RedisIndex..'filterlist:'..chat_id)
							text = Source_Start.."`لیست کلمات فیلتر شده پاک شد`"..EndMsg
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="filterlist:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanrules:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						local rules = redis:get(RedisIndex..chat_id..'rules')
						if not rules then
							text = Source_Start.."قوانین گروه ثبت نشده"..EndMsg
						else
							text = Source_Start.."قوانین گروه پاک شد"..EndMsg
							redis:del(RedisIndex..chat_id..'rules')
						end
						keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="rules:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'cleanwlcmsg:'..chat_id and Ownercheck(Msg, chat_id, user_id, user_first) then
						local wlc = redis:get(RedisIndex..'welcome:'..chat_id)
						if not wlc then
							text = Source_Start.."پیام خوشامد تنظیم نشده است"..EndMsg
						else
							text = Source_Start..'پیام خوشامد حذف شد'..EndMsg
							redis:del(RedisIndex..'welcome:'..chat_id)
						end
						local keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start.."بازگشت", callback_data="showwlc:"..chat_id}
						}
						}
						EditInline(msg.inline_id, text, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'Tabchi:'..chat_id and redis:get(RedisIndex.."usertabchi:"..chat_id..user_id) then
						redis:hdel(RedisIndex..chat_id..':warntabchi', user_id, '0')
						user = '['..user_id..'](tg://user?id='..user_id..')'
						EditInline(msg.inline_id, Source_Start.."`کاربر` "..user.." - *"..es_name(user_first).."* `شناسای شد`"..EndMsg, chat_id, msg_id, "md")
					end
					if CmdMatches == 'ExitPanel:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						user = '['..user_id..'](tg://user?id='..user_id..')'
						EditInline(msg.inline_id, Source_Start.."`پنل مدیرتی ربات توسط` "..user.." - *"..es_name(user_first).."* `بسته شد`"..EndMsg, chat_id, msg_id, "md")
					end
					if CmdMatches == 'ExitHelp:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						user = '['..user_id..'](tg://user?id='..user_id..')'
						EditInline(msg.inline_id, Source_Start.."`پنل راهنمای ربات توسط` "..user.." - *"..es_name(user_first).."* `بسته شد`"..EndMsg, chat_id, msg_id, "md")
					end
					if CmdMatches == 'Manager:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						user = '['..user_id..'](tg://user?id='..user_id..')'
						local keyboard = {}
						keyboard.inline_keyboard = {
						{
						{text = Source_Start..'لینک گروه پشتیبانی', url = ''..link_poshtibani..''}
						},
						{
						{text = Source_Start..'سازنده ربات', url = 'http://t.me/'..sudoinline_username..''},
						{text = Source_Start..'کانال ما', url = 'http://t.me/'..channel_inline..''}
						},
						{
						{text = Source_Start..'درگاه پرداخت', url = ''..linkpardakht..''}
						},
						{
						{text = Source_Start.."بازگشت", callback_data = "MenuSettings:"..chat_id}
						}
						}
						EditInline(msg.inline_id, Source_Start.."`کاربر` "..user.." - *"..es_name(user_first).."* `به پشتیبانی ربات خوشآمدید`"..EndMsg, chat_id, msg_id, "md" ,keyboard)
					end
					if CmdMatches == 'HelpCode:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						HelpCode(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'Helplock:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						LockHelp(msg.inline_id, chat_id, msg_id)
					end
					if CmdMatches == 'Helpmod:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						Text = Config.helpmod
						local keyboard = {}
						keyboard.inline_keyboard = {{{text = Source_Start.."ادامه", callback_data="Helpmod_b:"..chat_id}},{{text = Source_Start.."بازگشت", callback_data="HelpCode:"..chat_id}}}
						EditInline(msg.inline_id, Text, chat_id, msg_id, "md",keyboard)
					end
					if CmdMatches == 'Helpmod_b:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						Text = Config.helpmod_b
						local keyboard = {}
						keyboard.inline_keyboard = {{{text = Source_Start.."ادامه", callback_data="Helpmod_c:"..chat_id}},{{text = Source_Start.."بازگشت", callback_data="Helpmod:"..chat_id}}}
						EditInline(msg.inline_id, Text, chat_id, msg_id, "md",keyboard)
					end
					if CmdMatches == 'Helpmod_c:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						Text = Config.helpmod_c
						local keyboard = {}
						keyboard.inline_keyboard = {{{text = Source_Start.."بازگشت", callback_data="Helpmod_b:"..chat_id}}}
						EditInline(msg.inline_id, Text, chat_id, msg_id, "md",keyboard)
					end
					if CmdMatches == 'Helpset:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						Text = Config.helpset
						local keyboard = {}
						keyboard.inline_keyboard = {{{text = Source_Start.."بازگشت", callback_data="HelpCode:"..chat_id}}}
						EditInline(msg.inline_id, Text, chat_id, msg_id, "md",keyboard)
					end
					if CmdMatches == 'Helpclean:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						Text = Config.helpclean
						local keyboard = {}
						keyboard.inline_keyboard = {{{text = Source_Start.."ادامه", callback_data="Helpclean_b:"..chat_id}},{{text = Source_Start.."بازگشت", callback_data="HelpCode:"..chat_id}}}
						EditInline(msg.inline_id, Text, chat_id, msg_id, "md",keyboard)
					end
					if CmdMatches == 'Helpclean_b:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
						Text = Config.helpclean_b
						local keyboard = {}
						keyboard.inline_keyboard = {{{text = Source_Start.."بازگشت", callback_data="Helpclean:"..chat_id}}}
						EditInline(msg.inline_id, Text, chat_id, msg_id, "md",keyboard)
					end
					if CmdMatches == 'Hlink:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "link", "لینک")
end
if CmdMatches == 'Hforch:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "forward", "فوروارد کانال")
end
if CmdMatches == 'Hforus:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "forward user", "فوروارد کاربر")
end
if CmdMatches == 'Htag:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "tag", "تگ")
end
if CmdMatches == 'Hman:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "mention", "منشن")
end
if CmdMatches == 'Hfarsi:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "farsi", "فارسی")
end
if CmdMatches == 'Hedit:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "edit", "ویرایش")
end
if CmdMatches == 'Hfont:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "markdown", "فونت")
end
if CmdMatches == 'Hweb:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "webpage", "وب")
end
if CmdMatches == 'Hgif:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "gif", "گیف")
end
if CmdMatches == 'Htext:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "text", "متن")
end
if CmdMatches == 'Hphoto:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "photo", "عکس")
end
if CmdMatches == 'Hvideo:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "video", "فیلم")
end
if CmdMatches == 'Hself:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "video_note", "فیلم سلفی")
end
if CmdMatches == 'Haudio:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "audio", "آهنگ")
end
if CmdMatches == 'Hvoice:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "voice", "ویس")
end
if CmdMatches == 'Hsticker:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "sticker", "استیکر")
end
if CmdMatches == 'Hmokha:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "contact", "مخاطب")
end
if CmdMatches == 'Hloc:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "location", "موقعیت")
end
if CmdMatches == 'hfile:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "document", "فایل")
end
if CmdMatches == 'Hinline:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "inline", "کیبورد شیشه ای")
end
if CmdMatches == 'Hgame:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "game", "بازی")
end
if CmdMatches == 'Hviewo:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "views", "ویو")
end
if CmdMatches == 'Hkeybord:'..chat_id and Modcheck(Msg, chat_id, user_id, user_first) then
LockMsg(msg.inline_id, chat_id, msg_id, "keyboard", "صفحه کلید")
end
				end
			end
		end
	end
end
return RunHelper()

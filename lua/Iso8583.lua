-- Wireshark Plugin for 8583, author: JackHao<north0808@qq.com>
-- Api http://www.cse.sc.edu/~okeefe/tutorials/wireshark/wsluarm_modules.html

-- debug
-- local debug = require("debugger")
-- require("mobdebug").start()

-- 配置参数
-- do not modify this table
local eDebugLevel = {
  Error = 0,-- Error
  Warn  = 1,-- Warn
  Info  = 2, -- Info
  Debug = 3 -- Debug
}

local eBitmapType =
  {
    N,
    Z,
    B,
    A,

    N_LLVAR,
    Z_LLVAR,
    B_LLVAR,
    A_LLVAR,

    N_LLLVAR,
    Z_LLLVAR,
    B_LLLVAR,
    A_LLLVAR,

    Unknow,
  }

-- 域定义
local eMapBitmap = {
  [0]={"未知域", "Unknow Bitmap", nil},
  [1]={"域1 扩展域", "Bitmap Table", nil},
  [2]={"域2 主账号", "Primary Account Number", "N..19(LLVAR)"},
  [3]={"域3 交易处理码", "Transaction Processing Code", "N6"},
  [4]={"域4 交易金额", "Amount Of Transactions", "N12"},
  [11]={"域11 受卡方系统跟踪号", "System Trace Audit Number", "N6"},
  [12]={"域12 受卡方所在地时间", "Local Time Of Transaction", "N6"},
  [13]={"域13 受卡方所在地日期", "Local Date Of Transaction", "N4"},
  [14]={"域14 卡有效期", "Date Of Expired", "N4"},
  [15]={"域15 清算日期", "Date Of Settlement", "N4"},
  [22]={"域22 服务点输入方式码", "Point Of Service Entry Mode", "N3"},
  [23]={"域23 卡序列号", "Card Sequence Number", "N3"},
  [25]={"域25 服务点条件码", "Point Of Service Condition Mode", "N2"},
  [26]={"域26 服务点PIN获取码", "Point Of Service PIN Capture Code", "N2"},
  [32]={"域32 受理机构标识码", "Acquiring Institution Identification Code", "N..11(LLVAR)"},
  [35]={"域35 2磁道数据", "Track 2 Data", "Z..37(LLVAR)"},
  [36]={"域36 3磁道数据", "Track 3 Data", "Z...104(LLLVAR)"},
  [37]={"域37 检索参考号", "Retrieval Reference Number", "AN12"},
  [38]={"域38 授权标识应答码", "Authorization Identification Response Code", "AN6"},
  [39]={"域39 应答码", "Response Code", "AN2"},
  [41]={"域41 受卡机终端标识码", "Card Acceptor Terminal Identification", "ANS8"},
  [42]={"域42 受卡方标识码", "Card Acceptor Identification Code", "ANS15"},
  [44]={"域44 附加响应数据", "Additional Response Data", "AN..25(LLVAR)"},
  [48]={"域48 附加数据- 私有", "Additional Data - Private", "N...322(LLLVAR)"},
  [49]={"域49 交易货币代码", "Currency Code Of Transaction", "AN3"},
  [52]={"域52 个人标识码数据", "PIN Data", "B64"},
  [53]={"域53 安全控制信息", "Security Related Control Information ", "n16"},
  [54]={"域54 余额", "Balanc Amount", "AN...020(LLLVAR)"},
  [55]={"域55 IC卡数据域", "Intergrated Circuit Card System Related Data", "ANS...255(LLLVAR)"},
  [58]={"域58 PBOC电子钱包标准的交易信息（PBOC_ELECTRONIC_DATA）", "ans...100(LLLVAR)"},
  [60]={"域60 自定义域", "Reserved Private", "N...17(LLLVAR)"},
  [61]={"域61 原始信息域", "Original Message", "N...029(LLLVAR)"},
  [62]={"域62 自定义域", "Reserved Private", "ANS...512(LLLVAR)"},
  [63]={"域63 自定义域", "Reserved Private", "ANS...163(LLLVAR)"},
  [64]={"域64 报文鉴别码", "Message Authentication Code", "B64"},
  [65]={"域65 巡检工作内容报告，工作内容（10位）数字字符，机具状态（1位数字字符）", "Check Content", "N11"},
  [66]={"域66 使用优惠券列表", "Member Coupons List", "ANS...999(LLLVAR)"},
  [67]={"域67 可用优惠券剩余列表", "Merchant Coupons List", "B...999(LLLVAR)"},
  [68]={"域68 会员编号，用作会员的标识。本系统使用手机号作为会员编号", "Member ID", "N..64(LLVAR)"},
  [71]={"域71 会员编号，用作会员的标识。本系统使用手机号作为会员编号", "Member ID", "N11"},
  [72]={"域72 会员级别编号", "Member Lever Number", "N1"},
  [73]={"域73 会员可以享有的折扣", "Member Discount", "N4"},
  [74]={"域74 使用优惠券列表", "Member Coupons List", "ANS...999(LLLVAR)"},
  [75]={"域75 可用优惠券剩余列表", "Merchant Coupons List", "A...999(LLLVAR)"},
  [76]={"域76 会员积分余额", "MemberPoints Balance", "N10"},
  [77]={"域77 券号", "Coupons ID", "N..30(LLVAR)"},
  [78]={"域78 通讯信息", "Term Comm Info", "N..30(LLVAR)"},
  [79]={"域79 原交易类型码", "Old Trans Type", "N2"},
  [80]={"域80 会员消费现金额", "Member Consume Cash", "N12"},
  [81]={"域81 会员消费积分额", "Member Consume Points", "N10"},
  [82]={"域82 应答信息", "Response Info", "ANS..48(LLVAR)"},
  [83]={"域83 终端操作员号", "Terminal OperatorNo", "N3"},
  [84]={"域84 报文格式信息", "Packet Info", "B..20(LLVAR)"},
  [88]={"域88 商户简称", "Merchant Name", "ANS..40(LLVAR)"},
  [89]={"域89 会员可用积分余额", "MemberPointsAvailable Balance", "N10"},
  [95]={"域95 查询结果批号", "QueryNo", "N3"},
  [96]={"域96 退货类查询结果", "QueryResult", "ANS...999(LLLVAR)"},
  [104]={"域104 设备序列号", "Device Serial Number", "ANS16"},
  [105]={"域105 终端业务参数", "Terminal Function PARA", "ANS...400(LLLVAR)"},
  [106]={"域106 业务规则编号", "Rules Number", "N2"},
  [107]={"域107 业务规则信息", "Rules Info", "ANS..16(LLVAR)"},
  [108]={"域108 报文序号", "Packet Serial Number", "N6"},
  [109]={"域109 报文后续标识", "Packet Flag", "N1"},
  [110]={"域110 会员折扣计算标识", "Member Discount Flag", "N1"},
  [111]={"域111 信息同步参数", "TMS Params Sync", "ANS..20(LLVAR)"},
  [112]={"域112 会员级别信息", "Member Level Info", "ANS..99(LLVAR)"},
  [113]={"域113 终端应用编号", "Application Number", "ANS6"},
  [114]={"域114 终端应用版本号", "Application Version", "ANS6"},
  [115]={"域115 自定义参数", "Self PARA", "ANS..256(LLLVAR)"},
  [116]={"域116 POS健康度信息", "Healthy Info", "ANS...256(LLLVAR)"},
  [117]={"域117 终端应用参数", "Terminal App PARA", "ANS...512(LLLVAR)"},
  [118]={"域118 POS持卡人广告信息", "Cardholder Advertising Info", "ANS...999(LLLVAR)"},
  [119]={"域119 POS商户广告信息", "Merchant Advertising Info", "ANS...999(LLLVAR)"},
  [120]={"域120 POS最新动态", "Update Situation", "ANS...999(LLLVAR)"},
  [128]={"域128 BITMAP为128位时的MAC", "128 Bitmap's Mac", "B64"},
}

-- 消息类型
local eMapMessageType = {
  [100]=[[
—— 0100/0110授权类请求/应答消息：
● 预授权请求/应答。
● 预授权撤销请求/应答。
● 磁条卡现金充值账户验证请求/应答。
]],
  [200]=[[
—— 0200/0210金融类请求/应答消息：
● 查询请求/应答。
● 消费请求/应答。
● 消费撤销请求/应答。
● 预授权完成（请求）请求/应答。
● 预授权完成撤销请求/应答。
● 电子现金脱机消费请求/应答。
● 分期付款交易请求/应答。
● 分期付款交易撤销请求/应答。
● 基于PBOC电子钱包/电子现金的IC圈存类交易请求/应答。
● 磁条卡现金充值请求/应答。
● 磁条卡账户充值请求/应答。
]],
  [220]=[[
—— 0220/0230金融通知类请求/应答消息：
● 退货通知请求/应答。
● 离线结算通知请求/应答。
● 结算调整通知请求/应答。
● 预授权完成（通知）请求/应答。
● 磁条卡现金充值确认通知请求/应答。
]],
  [320]=[[
—— 0320/0330 批上送消息请求/应答：
● 终端批上送请求/应答。
]],
  [400]=[[
—— 0400/0410冲正类消息请求/应答：
● 预授权冲正请求/应答。
● 预授权撤销冲正请求/应答。
● 消费冲正请求/应答。
● 消费撤销冲正请求/应答。
● 预授权完成（请求）冲正请求/应答。
● 预授权完成撤销冲正请求/应答。
● 基于PBOC电子钱包/电子现金的IC圈存类交易冲正请求/应答
]],
  [500]=[[
—— 0500/0510对账类消息请求/应答：
● 终端批结算请求/应答。
]],
  [620]=[[
—— 0620/0630基于PBOC借/贷记卡标准的IC卡脚本处理结果通知消息请求/应答：
● 基于PBOC借/贷记卡标准的IC卡脚本处理结果通知请求/应答。
]],
  [800]=[[
—— 0800/0810网络业务管理类消息请求/应答：
● 终端签到请求/应答。
● 终端参数传递请求/应答。
]],
  [820]=[[
—— 0820/0830网络业务管理类消息请求/应答：
● 终端签退请求/应答。
● 终端回响测试请求/应答。
● 终端状态上送请求/应答。
● 收银员积分签到请求/应答。
]],
}

-- set this DEBUG to debugLevel.Warn to enable printing debugLevel info
-- set it to debugLevel.Info to enable really verbose printing
-- note: this will be overridden by user's preference settings
local eSettings =
  {
    debugLevel      = eDebugLevel.Error,
    mapBitmap       = eMapBitmap,
    port            = {5555, 6666},
    log_enabled     = true,
    log_gui_enabled = true,
    protoName       = "Iso8583_Bank",
    protoInfo       = "JackHao<north0808@qq.com>'s Plugin For ISO8583",
  }

-- 设置日志方法
local logError = function() end
local logWarn = function() end
local logInfo = function() end
local logDebug = function() end
local win = nil

do
  local function log_win(log_msg)
    if not gui_enabled() or not eSettings.log_gui_enabled then
      return
    else
    -- 打开下面的开关禁用Log窗口
    -- return
    end

    if not win then
      win = TextWindow.new("Log")
      win:set_editable(true)

      win:add_button("Clear", function()
        win:clear()
      end)

      win:add_button("Uppercase", function()
        local text = win:get_text()

        if text ~= "" then
          win:set(string.upper(text))
        end
      end)

      win:add_button("Lowercase", function()
        local text = win:get_text()

        if text ~= "" then
          win:set(string.lower(text))
        end
      end)

      win:set_atclose(function()
        print("close")
      end)
    end
    -- create new text window and initialize its text
    win:append(log_msg)
  end
  local function resetDebugLevel()
    if eSettings.debugLevel >= eDebugLevel.Error then
      logError = function(...)
        local log_msg = "[Error] "..table.concat({eSettings.protoName..",", ...}," ").."\n"
        error(log_msg)
        log_win(log_msg)
      end

      if eSettings.debugLevel >= eDebugLevel.Warn then
        logWarn = function(...)
          local log_msg = "[Warn] "..table.concat({eSettings.protoName..",", ...}," ").."\n"
          warn(log_msg)
          log_win(log_msg)
        end
      end

      if eSettings.debugLevel >= eDebugLevel.Info then
        logInfo = function(...)
          local log_msg = "[Info] "..table.concat({eSettings.protoName..",", ...}," ").."\n"
          info(log_msg)
          log_win(log_msg)
        end
      end

      if eSettings.debugLevel >= eDebugLevel.Debug then
        logDebug = function(...)
          local log_msg = "[Debug] "..table.concat({eSettings.protoName..",", ...}," ").."\n"
          debug(log_msg)
          log_win(log_msg)
        end
      end
    end
  end
  -- call it now
  resetDebugLevel()
end

local data_dis = Dissector.get("data")

logInfo("Developer: JackHao"..eSettings.protoInfo)
logInfo("Wireshark version = "..get_version())
logInfo("Lua version = ".._VERSION)

------------------------------------------------------------------------------
-- Unfortunately, the older Wireshark/Tshark versions have bugs, and part of the point
-- of this script is to test those bugs are now fixed.  So we need to check the version
-- end error out if it's too old.
-- 1.99.5
local major, minor, micro = get_version():match("(%d+)%.(%d+)%.(%d+)")
if major and tonumber(major) <= 1 and ((tonumber(minor) <= 10) or (tonumber(minor) == 11 and tonumber(micro) < 3)) then
  error(  "Sorry, but your Wireshark/Tshark version ("..get_version()..") is too old for this script!\n"..
    "This script needs Wireshark/Tshark version 1.11.3 or higher.\n" )
end

-- more sanity checking
-- verify we have the ProtoExpert class in wireshark, as that's the newest thing this file uses
assert(ProtoExpert.new, "Wireshark does not have the ProtoExpert class, so it's too old - get the latest 1.11.3 or higher")

------------------------------------------------------------------------------
-- creates a Proto object, but doesn't register it yet
local proto = Proto(eSettings.protoName, eSettings.protoInfo) -- , base.DEC
-- 添加字段
do
  -- length
  local pf_totalLen                   = ProtoField.new   ("Length", eSettings.protoName..".total_len",              ftypes.UINT16, nil, base.HEX) --2 byte
  -- tpdu
  local pf_tpdu                       = ProtoField.new   ("TPDU", eSettings.protoName..".tpdu",                     ftypes.UINT64, nil, base.HEX, 0xFFFFFFFFFF) --5 byte
  local pf_tpdu_id                    = ProtoField.new   ("TPDU ID", eSettings.protoName..".tpdu.id",               ftypes.UINT8, nil, base.HEX, 0x8000) -- 1 byte
  local pf_tpdu_dstAddr               = ProtoField.new   ("TPDU Dest Addr", eSettings.protoName..".tpdu.dst_addr",  ftypes.UINT16, nil, base.HEX, 0x8000) -- 2 byte
  local pf_tpdu_srcAddr               = ProtoField.new   ("TPDU Src Addr", eSettings.protoName..".tpdu.src_addr",   ftypes.UINT16, nil, base.HEX, 0x8000) -- 2 byte
  -- header
  local pf_header                     = ProtoField.new   ("Header", eSettings.protoName..".header",                 ftypes.UINT64, nil, base.HEX, 0xFFFFFFFFFFFF) --6 byte
  local pf_header_class               = ProtoField.new   ("Header Class", eSettings.protoName..".header.class",     ftypes.BOOLEAN, {"this is a response","this is a query"}, base.HEX, 0x8000)
  local pf_header_softTotalVersion    = ProtoField.new   ("Header Soft Total Version", eSettings.protoName..".header.soft_total_version",           ftypes.BOOLEAN, {"this is a response","this is a query"}, base.HEX, 0x8000)
  local pf_header_terminalStatus      = ProtoField.new   ("Header Terminal Status", eSettings.protoName..".header.terminal_status",                 ftypes.BOOLEAN, {"this is a response","this is a query"}, base.HEX, 0x8000)
  local pf_header_terminalStatus      = ProtoField.new   ("Header Processing Requirements", eSettings.protoName..".header.processing_requirements", ftypes.BOOLEAN, {"this is a response","this is a query"}, base.HEX, 0x8000)
  local pf_header_softSepVersion      = ProtoField.new   ("Header Soft Sep Version", eSettings.protoName..".header.soft_sep_version",               ftypes.BOOLEAN, {"this is a response","this is a query"}, base.HEX, 0x8000)
  -- data
  local pf_data                       = ProtoField.new   ("Data", eSettings.protoName..".data",                     ftypes.UINT16, nil, base.HEX, 0xFFFF) --2 byte

  proto.fields = { pf_totalLen, pf_tpdu, pf_tpdu_id, pf_tpdu_dstAddr, pf_tpdu_srcAddr, pf_header, pf_header_class, pf_header_softTotalVersion, pf_header_terminalStatus, pf_header_softSepVersion, pf_data}
  -- proto.prefs["tcp_port"] = Pref.uint("TCP Port", eSettings.port, "TCP Port for ISO8583")
end
-- [[process Start]]
----------------------------------------------------------------------------
-- str to utf8
----------------------------------------------------------------------------
local function MyToUtf8(str)
  -- [[MyToUtf8 Start]]
  return ""
    -- [[MyToUtf8 Start]]
end

----------------------------------------------------------------------------
-- Hex to BCD 0x373839 => "373839"
----------------------------------------------------------------------------
local function MyHex2BCD(hex)
  -- [[MyHex2BCD Start]]
  local result = tostring(hex)

  return result;
-- [[MyHex2BCD Start]]
end

----------------------------------------------------------------------------
-- Hex to str "373839" => "789"
----------------------------------------------------------------------------
local function MyHex2Str(str)
  -- [[MyHex2Str Start]]
  if not (string.len(str)%2 ==0) then
    return str
  else
    local s = ""

    for i = 1, string.len(str), 2 do
      s = s..string.char(tonumber("0x"..string.sub(str, i, i+1)))
    end

    return s
  end
  -- [[MyHex2Str End]]
end

----------------------------------------------------------------------------
-- 根据公式计算长度(bytes)
-- buf      : 当前正在处理的域buf
-- rule     : 计算域的值的公式（如N2）
-- postion  : 域序号（1-128）
----------------------------------------------------------------------------
local function MyCalcBitmapPostLen(buf, rule, postion)
  -- [[MyCalcBitmapPostLen Start]]
  local TAG = "MyCalcBitmapPostLen: "
  if rule then
    logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf)
  else
    logDebug(TAG.."postion(1-128) = "..postion..", rule = nil, buf[IN "..buf:len().."] = "..buf)
  end
  --[[
    数据元类型如下所列：
 —— A字母向左靠，右部多余部分填空格。
 —— AN字母和/或数字，左靠，右部多余部分填空格。
 —— ANS字母、数字和/或特殊符号，左靠，右部多余部分填空格。
 —— AS字母和/或特殊符号，左靠，右部多余部分填空格。
 —— B二进制bit位。
 —— DD日。
 —— hh时。
 —— LL可变长域的长度值(二位数)。
 —— LLL 可变长域的长度值(三位数)。
 —— MM 月。
 —— mm 分。
 —— N数值，右靠，首位有效数字前充零。若表示金额，则最右二位为角分。
 —— S特殊符号。
 —— ss秒。
 —— VAR可变长域。
 —— X借贷符号，在数值之前，D表示借，C表示贷。
 —— YY年。
 —— Z 由ISO 7811和ISO 7813制定的磁条卡第二、三磁道的数据类型。
 —— CNBCD压缩编码数值。

 符号定义
—— M强制域(Mandatory)，此域在该消息中必须出现否则将被认为消息格式出错。
—— C条件域(Conditional)，此域在一定条件下出现在该消息中，具体的条件请参考备注中的说明。
—— O选用域(Optional)，此域在该消息中由发送方自选。
—— Space此域在该种消息中不出现。
—— A 字母a－z
—— n 数字0－9
—— s 特殊字符
—— an 字母和数字字符
—— ans 字母、数字和特殊字符
—— MM 月
—— DD 日
—— YY 年
—— hh 小时
—— mm 分
—— ss 秒
—— LL 允许的最大长度为99
—— LLL 允许的最大长度为999
—— VAR 可变长度域
—— b 数据的二进制表示，后跟数字表示位（bit）的个数
—— B 用于表示变长的二进制数，后跟数字表示二进制数据所占字节（Byte）的个数
—— z 按GB/T 15120和GB/T 17552的2、3磁道编码
—— cn BCD压缩编码数值
    ]]

  -- 物理存储字节数，转换成字符串后的字符数，eBitmapType，内容
  local result = {[1]=0, [2]=0, [3]=eBitmapType.Unknow, [4]=""}

  if not rule then
    return result
  end

  if string.len(rule)==0 then
    return result
  end
  -- 转成大写
  rule = string.upper(rule)

  -- LLVAR
  local max = tonumber(string.match(rule, "^[A-Z]+%.+(%d+)%(LLVAR%)$") or "0")
  local len = 0


  if max>99 then
    max=99
  end

  if max>0 then
    len = tonumber(MyHex2BCD(buf(0, 1)))

    --N,Z
    local len_n = tonumber(string.match(rule, "^N%.+(%d+)%(LLVAR%)$") or "0")
    local len_z = tonumber(string.match(rule, "^Z%.+(%d+)%(LLVAR%)$") or "0")

    if len_n >0 or len_z >0 then
      if len < max then
        result[1] = math.floor((len + 1)/2) + 1
        result[2] = len
      else
        result[1] = math.floor((max + 1)/2) + 1
        result[2] = max
      end

      if len_n >0 then
        result[3] = eBitmapType.N_LLVAR
        result[4] = MyHex2BCD(buf(1, result[1]-1));
      else
        result[3] = eBitmapType.Z_LLVAR
        result[4] = MyHex2BCD(buf(1, result[1]-1));
      end

      logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
      return result
    end

    --B
    if tonumber(string.match(rule, "^B%.+(%d+)%(LLVAR%)$") or "0") >0 then
      if len < max then
        result[1] = math.floor((len + 7)/8) + 1
        result[2] = len
      else
        result[1] = math.floor((max + 7)/8) + 1
        result[2] = max
      end
      result[3] = eBitmapType.B_LLVAR
      result[4] = MyHex2BCD(buf(1, result[1]-1));

      logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
      return result
    end

    --A
    if tonumber(string.match(rule, "^[A-Z]+%.+(%d+)%(LLVAR%)$") or "0") >0 then
      if len < max then
        result[1] = len + 1
        result[2] = len
      else
        result[1] = max + 1
        result[2] = max
      end
      result[3] = eBitmapType.A_LLVAR
      result[4] = MyHex2BCD(buf(1, result[1]-1));

      logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
      return result
    end
    logError("Unknow rule for (LLVAR): "..rule)

    return result
  end

  -- LLLVAR
  max = tonumber(string.match(rule, "..(%d+)%(LLLVAR%)$") or "0")
  len = 0

  if max>999 then
    max=999
  end

  if max>0 then
    len = math.floor((tonumber(tonumber(MyHex2BCD(buf(0, 2)))) or 0)%1000)

    logDebug(rule..", max="..max..", len="..len)
    --N,Z
    local len_n = tonumber(string.match(rule, "^N%.+(%d+)%(LLLVAR%)$") or "0")
    local len_z = tonumber(string.match(rule, "^Z%.+(%d+)%(LLLVAR%)$") or "0")

    if len_n >0 or len_z >0 then
      if len < max then
        result[1] = math.floor((len + 1)/2) + 2
        result[2] = len
      else
        result[1] = math.floor((max + 1)/2) + 2
        result[2] = max
      end

      if len_n >0 then
        result[3] = eBitmapType.N_LLLVAR
        result[4] = MyHex2BCD(buf(2, result[1]-2));
      else
        result[3] = eBitmapType.Z_LLLVAR
        result[4] = MyHex2BCD(buf(2, result[1]-2));
      end

      logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
      return result
    end

    --B
    if tonumber(string.match(rule, "^B%.+(%d+)%(LLLVAR%)$") or "0") >0 then
      if len < max then
        result[1] = math.floor((len + 7)/8) + 2
        result[2] = len
      else
        result[1] = math.floor((max + 7)/8) + 2
        result[2] = max
      end
      result[3] = eBitmapType.B_LLLVAR
      result[4] = MyHex2BCD(buf(2, result[1]-2));

      logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
      return result
    end

    --A
    if tonumber(string.match(rule, "^[A-Z]+%.+(%d+)%(LLLVAR%)$") or "0") >0 then
      if len < max then
        result[1] = len + 2
        result[2] = len
      else
        result[1] = max + 2
        result[2] = max
      end
      result[3] = eBitmapType.A_LLLVAR
      result[4] = MyHex2BCD(buf(2, result[1]-2));

      logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
      return result
    end
    logError("Unknow rule for (LLLVAR): "..rule)

    return result
  end

  --N
  len = tonumber(string.match(rule, "^N(%d+)$") or "0")
  if len >0 then
    result[1] = math.floor((len + 1)/2)
    result[2] = len
    result[3] = eBitmapType.N
    result[4] = MyHex2BCD(buf(0, result[1]));

    logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
    return result
  end

  --Z
  len = tonumber(string.match(rule, "^Z(%d+)$") or "0")
  if len >0 then
    result[1] = math.floor((len + 1)/2)
    result[2] = len
    result[3] = eBitmapType.Z
    result[4] = MyHex2BCD(buf(0, result[1]));

    logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
    return result
  end

  --B
  len = tonumber(string.match(rule, "^B(%d+)$") or "0")
  if len >0 then
    result[1] = math.floor((len + 7)/8)
    result[2] = len
    result[3] = eBitmapType.B
    result[4] = MyHex2BCD(buf(0, result[1]));

    logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
    return result
  end

  --A
  len = tonumber(string.match(rule, "^[A-Z]+(%d+)$") or "0")
  if len >0 then
    result[1] = len
    result[2] = len
    result[3] = eBitmapType.A
    -- result[4] = MyHex2BCD(buf(0, result[1]));
    result[4] = "";

    logDebug(TAG.."postion(1-128) = "..postion..", rule = "..rule..", buf[IN "..buf:len().."] = "..buf..", bytes len ="..result[1]..", str len = "..result[2])
    return result
  end
  logError("Unknow rule for XX0-9[postion(1-128) = "..postion.."]: rule[IN "..buf:len().."] = "..rule..", buf = "..buf)

  return result
    -- [[MyCalcBitmapPostLen End]]
end

----------------------------------------------------------------------------
-- 计算bitmap中某个控制位对应的域数据的物理bytes offset（相对于域数据部分，控制位之后的数据部分）
-- mapBitmap  : 包含每个域的长度的table
-- postion    : 域序号（1-128）
----------------------------------------------------------------------------
local function MyCalcBitmapPosOffset(mapBitmap, postion)
  -- [[MyCalcBitmapPosOffset Start]]
  local offset = 0

  if postion<=1 then
    return offset
  end

  for i = 1, postion-1, 1 do
    if mapBitmap[i] then
      offset = offset + mapBitmap[i][1]
    end
  end

  return offset
    -- [[MyCalcBitmapPosOffset End]]
end

----------------------------------------------------------------------------
-- 计算bitmap中某个控制位对应的域数据的offset（相对于域数据部分，控制位之后的数据部分）
-- mapBitmapItem  : mapBitmap 中的第（offsetPos+postion） 个域
----------------------------------------------------------------------------
local function  MyGetBitmapPosValue(mapBitmapItem)
  -- [[MyGetBitmapPosValue Start]]
  local str = mapBitmapItem[4]

  if 1==1 then
    return str..", "..MyHex2Str(str)..", "..string.sub(str, 1, mapBitmapItem[2])
  end

  if pos == 37 or pos == 41 or pos == 42 or pos == 49 or pos == 64 then
    return MyHex2Str(str)
  else
    if mapBitmapItem[2] == string.len(str) then
      return str
    end
  end
  -- [[MyGetBitmapPosValue End]]
end

----------------------------------------------------------------------------
-- TODO 根据AppData获取消息类型：消费，冲正等等
-- messageType: AppData(0800/0810、0820/0821)
----------------------------------------------------------------------------
local function MyGetMessageType(messageType)
  -- [[MyGetMessageType Start]]
  local TAG = "MyGetMessageType: "
  local index = tonumber(messageType or "0")
  local result = ""

  if index/10%2==0 then
    result = MyToUtf8(eMapMessageType[index])
  else
    result = MyToUtf8(eMapMessageType[index-10])
  end

  if not result then
    result = ""
  end

  return result
    -- [[MyGetMessageType End]]
end

----------------------------------------------------------------------------
-- 添加位图控制和数据部分
-- buf_src:   起点buf
-- tree:      位图数据树
-- offsetPos: 对应bitmapTable中的位图偏移量
----------------------------------------------------------------------------
local function processBitmap(buf_src, tree, offsetPos)
  -- [[processBitmap Start]]
  local TAG = "processBitmap: "
  local buf = buf_src(offsetPos)
  logDebug("================== Process Start ==================")
  logDebug(TAG.."Process Buf = "..MyHex2BCD(buf))
  local lenData = 0
  -- 二维数组1维：1-128，二维：物理存储字节数，转换成字符串后的字符数，eBitmapType，内容
  -- 例如: {4, 8, N8, ***}
  local mapBitmap = {}
  local bitmapIndexMin = 1
  local bitmapIndexMax = 64
  local bitmapIndexBytesLen = 8
  local bitmapIndexCount = 0

  -- 检查是否要扩展64域到128域
  if buf(0, 1):bitfield(0, 1)==1 then
    bitmapIndexMax = 128
    bitmapIndexBytesLen = 16
  end

  -- 整理Bitmap数据
  local sb = ""
  local offset = 0
  local bufItem
  for i = 1, bitmapIndexBytesLen, 1 do
    for j = 1, 8, 1 do
      -- 域索引：1-128
      local bitmapIndex = (i-1)*8+j

      if i==1 and j==1 then
        logDebug(TAG.."New Bitmap Index>>>>>>>>>>")
        -- 模块：计算域1
        do
          offset = 0
          bufItem = buf(offset, bitmapIndexBytesLen)
          mapBitmap[bitmapIndex] = {
            [1] = bitmapIndexBytesLen
            , [2] = bitmapIndexBytesLen*2
            , [3] = eBitmapType.N
            , [4] = MyHex2BCD(bufItem)
          }
          logDebug(TAG.."Bitmap Current Index(1-128) = "..bitmapIndex..", offset = "..offset..", buf("..mapBitmap[bitmapIndex][1]..") = "..MyHex2BCD(bufItem))
        end

        -- 模块：将域添加到GUI
        do
          local mapBitmapDefine = eSettings.mapBitmap[0]

          if eSettings.mapBitmap[bitmapIndex] then
            mapBitmapDefine = eSettings.mapBitmap[bitmapIndex]
          end
          local desc = string.format("Postion %d (%d bytes, len is %d): %s, %s(%s), %s"
            , bitmapIndex
            , mapBitmap[bitmapIndex][1]
            , mapBitmap[bitmapIndex][2]
            , mapBitmapDefine[3] or ""
            , MyToUtf8(mapBitmapDefine[1] or "")
            , mapBitmapDefine[2] or ""
            , MyGetBitmapPosValue(mapBitmap[bitmapIndex])
          )
          tree:add(bufItem, desc)
        end
      else
        local v = buf(i-1, 1):bitfield(j-1, 1)

        if v==1 then
          logDebug(TAG.."New Bitmap Index>>>>>>>>>>")
          -- 模块：计算存在的域个数
          do
            if string.len(sb)>0 then
              sb = sb.." "
            end
            sb = sb..bitmapIndex
            bitmapIndexCount = bitmapIndexCount+1
          end

          -- 模块：计算域1+
          do
            -- 计算域的偏移量
            offset = MyCalcBitmapPosOffset(mapBitmap, bitmapIndex)

            if offset>buf:len() then
              logError(TAG.."Bitmap calc error, bitmapIndex = "..bitmapIndex)
              return
            end
            -- 计算域的值
            local rule = nil

            if eSettings.mapBitmap[bitmapIndex] then
              rule = eSettings.mapBitmap[bitmapIndex][3]
            end
            mapBitmap[bitmapIndex] = MyCalcBitmapPostLen(buf(offset), rule, bitmapIndex)
            bufItem = buf(offset, mapBitmap[bitmapIndex][1])
            logDebug(TAG.."Bitmap Current Index(1-128) = "..bitmapIndex..", offset = "..offset..", buf("..mapBitmap[bitmapIndex][1]..") = "..MyHex2BCD(bufItem))
            lenData = lenData + mapBitmap[bitmapIndex][1]
          end

          -- 模块：将域添加到GUI
          do
            local mapBitmapDefine = nil

            if eSettings.mapBitmap[bitmapIndex] then
              mapBitmapDefine = eSettings.mapBitmap[bitmapIndex]
            else
              mapBitmapDefine = eSettings.mapBitmap[0]
            end
            local desc = string.format("Postion %d (%d bytes, len is %d): %s, %s(%s), %s"
              , bitmapIndex
              , mapBitmap[bitmapIndex][1]
              , mapBitmap[bitmapIndex][2]
              , mapBitmapDefine[3] or ""
              , MyToUtf8(mapBitmapDefine[1] or "")
              , mapBitmapDefine[2] or ""
              , MyGetBitmapPosValue(mapBitmap[bitmapIndex])
            )
            tree:add(buf(offset, mapBitmap[bitmapIndex][1]), desc)
          end
        end
      end
    end
  end
  logDebug(TAG.."itmapIndexCount(1-128："..sb..") = "..bitmapIndexCount)
  -- [[processBitmap End]]
end

----------------------------------------------------------------------------
-- 分析器
-- Buf(0,2):bitfield(0,2)
----------------------------------------------------------------------------
function proto.dissector(buf, pktInfo, tree)
  -- [[dissector Start]]
  local TAG = "dissector: "
  -- 不能小于从开始到位图控制器的最小长度需求
  if buf:len() < 34 then
    data_dis:call(buf, pktInfo, tree)
    return
  end

  -- 字节操作：buf(offset, len)
  local totalLen = 2 + tonumber(string.format("%d",buf(0, 2):uint()), 10)
  local subTree, subBuf

  if tonumber(MyHex2BCD(buf(14, 1)) or "0")/10%2 == 0 then
    pktInfo.cols.info = string.format("ISO8583 Request Data: %d bytes", totalLen)
    tree = tree:add(proto, buf(), "ISO8583 Request")
  else
    pktInfo.cols.info = string.format("ISO8583 Reponse Data: bytes", totalLen)
    tree = tree:add(proto, buf(), "ISO8583 Response")
  end

  -- 报文头 2bytes
  tree:add(buf(0, 2), string.format("Length: 2 bytes, %d", buf(0, 2):uint()))

  -- TPDU 5bytes
  subTree = tree:add(buf(2, 5), string.format("TPDU: 5 bytes, %s", MyHex2BCD(buf(2, 5):bytes())))
  do
    subBuf = buf(2,5)
    subTree:add(subBuf(0, 1), string.format("ID: 1 bytes, %s", MyHex2BCD(subBuf(0, 1):bytes())))
    subTree:add(subBuf(1, 2), string.format("Dest Addr: 2 bytes, %s", MyHex2BCD(subBuf(1, 2):bytes())))
    subTree:add(subBuf(3, 2), string.format("Src Addr: 2 bytes, %s", MyHex2BCD(subBuf(3, 2):bytes())))
  end

  -- Header 6bytes
  subTree = tree:add(buf(7, 6), string.format("Header: 6 bytes, %s", MyHex2BCD(buf(7, 6):bytes())))
  do
    subBuf = buf(7, 6)
    subTree:add(subBuf(0, 1), string.format("Class: 1 bytes, %s", MyHex2BCD(subBuf(0, 1):bytes())))
    subTree:add(subBuf(1, 1), string.format("Soft Total Version: 1 bytes, %s", MyHex2BCD(subBuf(1,1):bytes())))
    subTree:add(subBuf(2, 1), string.format("Terminal Status: 4 bits, %s", MyHex2BCD(subBuf(2, 1):bitfield(0, 4))))
    subTree:add(subBuf(2, 1), string.format("Processing Requirements: 4 bits, %s", MyHex2BCD(subBuf(2, 1):bitfield(4, 4))))
    subTree:add(subBuf(3, 3), string.format("Soft Sep Version: 3 bytes, %s", MyHex2BCD(subBuf(3, 3):bytes())))
  end

  subTree = tree:add(buf(13), string.format("ISO8583 Bitmap: %d bytes", buf(13):len()))
  -- 应用数据
  subBuf = buf(13)
  local messageType = MyHex2BCD(subBuf(0, 2):bytes())
  local info = string.format("App Data: 2 bytes, (%s), %s", MyGetMessageType(messageType), messageType)

  subTree:add(subBuf(0, 2), info)

  -- Bitmap Header + Data
  subBuf = buf(15)
  processBitmap(subBuf, subTree, 0)
  -- [[dissector End]]
end

function proto.init()
  -- [[init Start]]
  -- 添加本协议
  local tabTcp = DissectorTable.get("tcp.port")

  for i=1, #eSettings.port do
    tabTcp:add(tonumber(eSettings.port[i]), proto)
  end
  -- [[init End]]
end
-- [[process End]]


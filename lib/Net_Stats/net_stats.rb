require 'open-uri'

class Net_Stats < Geeklet
  
  AIRPORT_UTILITY = "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
  
  registerConfiguration :Net_Stats, :iface, :default => "en1", :description => "Interface to monitor", :type => :string
  registerConfiguration :Net_Stats, :wifi, :default => "yes", :description => "iface is a wireless interface", :type => :string
  registerConfiguration :Net_Stats, :server, :default => "google.com", :description => "ping server used for response time", :type => :string
  
  def description
    "Monitor your network stats"
  end
  
  def name
    "Net Stats"
  end
  
  def get_internal_ip
    ifc = %x{ifconfig #{@iface}}
    if ifc.grep(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)[0] == nil then
      iip = "none"
    else
      iip = ifc.grep(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)[0].strip.split(" ")[1]
    end
    return iip
  end
  
  def get_external_ip
    begin
      return %x{curl http://icanhazip.com}.strip
    rescue
      return "none"
    end
  end
  
  def get_access_point
    ap = %x{#{Net_Stats::AIRPORT_UTILITY} -I | grep ' SSID' | awk '{ print $2 }'}
    if ap.to_s == "" then
      return "none"
    else
      return ap.to_s.strip
    end
    #ap.to_s == "" ? return "none" : return ap
  end

  def get_response_time
    begin
      return %x{ping -c 1 -t 2 -Q #{@ping_server}}.grep(/round-trip/)[0].strip.split(" = ")[1].split("/")[2].to_f.round.to_s + "ms"
    rescue
      return "No Network"
    end
  end
  
  def get_txrx_totals
    rx = %x{netstat -ib | grep -e "#{@iface}" -m 1 | awk '{print $7}'}.to_i
    tx = %x{netstat -ib | grep -e "#{@iface}" -m 1 | awk '{print $10}'}.to_i
    return self.human_readable_bytes(tx) + " : " + self.human_readable_bytes(rx)
  end
  
  def human_readable_bytes(bytes)
    level = 0
    until bytes < 1024
      remainder = bytes % 1024
      bytes = bytes / 1024
      level += 1
    end
    remainder = ((remainder.to_f / 1024) * 100).to_i
    output = bytes.to_s + "." + remainder.to_s
    case level
    when 0
      output = output + " B"
    when 1
      output = output + " KB"
    when 2
      output = output + " MB"
    when 3
      output = output + " GB"
    when 4
      output = output + " TB"
    end
  end
  
  def run(params)
    super(:Net_Stats, params)
    
    @iface = configurableValue(:Net_Stats, :iface)
    @wifi = configurableValue(:Net_Stats, :wifi)
    @ping_server = configurableValue(:Net_Stats, :server)
    
    internal_ip = self.get_internal_ip
    external_ip = self.get_external_ip
    txrx = self.get_txrx_totals
    if @wifi == "yes" then
      access_point = self.get_access_point
    else
      access_point = "none"
    end
    if external_ip == "none" then
      ping_time = "No network"
    else
      ping_time = self.get_response_time
    end
    
    output = 
<<-EOS
 Internal IP : #{internal_ip}
 External IP : #{external_ip}
   Interface : #{@iface}
       TX:RX : #{txrx}
Access Point : #{access_point}
   Ping Time : #{ping_time} (#{@ping_server})
EOS
    puts output
  end
  
end
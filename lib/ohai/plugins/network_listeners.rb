#
# Author:: Doug MacEachern
# Copyright:: Copyright (c) 2009 Doug MacEachern
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#example output:
#  "network": {
#    "listeners": {
#      "tcp": {
#        "80": {
#          "name": "httpd",
#          "pid": 25,
#          "address": "*"
#        },
#        "1337": {
#          "name": "openvpn",
#          "pid": 5954,
#          "address": "127.0.0.1"
#        },
#  ...

require 'rbsigar'

provides "network/listeners"

require_plugin "network"

flags = Sigar::NETCONN_TCP|Sigar::NETCONN_SERVER

listeners = Mash.new

sigar = Sigar.new
sigar.net_connection_list(flags).each do |conn|
  port = conn.local_port
  addr = conn.local_address.to_s
  if addr == "0.0.0.0" || addr == "::"
    addr = "*"
  end
  listeners[port] = Mash.new
  listeners[port][:address] = addr
  begin
    pid = sigar.proc_port(conn.type, port)
    listeners[port][:pid] = pid
    listeners[port][:name] = sigar.proc_state(pid).name
    rescue
  end
end

network[:listeners] = Mash.new
network[:listeners][:tcp] = listeners

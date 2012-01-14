# Copyright (C) 2011 by Rik Halfmouw <rik@iwg.nl>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'cora'
require 'siri_objects'

#######
# This is plugin to return funny answers
######

class SiriProxy::Plugin::Jokes < SiriProxy::Plugin
  def initialize(config)
    appname = "Jokes"

  #show plugin status
  listen_for /^prettiest/i do 
  	say "Summer is the prettiest of them all"
  request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  listen_for /^cuttest/i do 
  	say "umm umm, it's me Cooper"
  request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end  

  # stop playing
  listen_for /^stop/i do 
    if (@xbmc.connect(@active_room))
      if @xbmc.stop()
        say "I stopped the video player"
      else
        say "There is no video playing"
      end
    end
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  # pause playing
  listen_for /^pause/i do 
    if (@xbmc.connect(@active_room))
      if @xbmc.pause()
        say "I paused the video player"
      else
        say "There is no video playing"
      end
    end
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  # resume playing
  listen_for /^resume|unpause|continue/i do 
    if (@xbmc.connect(@active_room))
      if @xbmc.pause()
        say "I resumed the video player", spoken: "Resuming video"
      else
        say "There is no video playing"
      end
    end
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  # set default room
  # set default room
  listen_for /(?:(?:[Ii]'m in)|(?:[Ii] am in)|(?:[Uu]se)|(?:[Cc]ontrol)) the (.*)/i do |roomname|
    roomname = roomname.downcase.strip
    if (roomname != "" && roomname != nil && @roomlist.has_key?(roomname))
      @active_room = roomname
      say "Noted.", spoken: "Commands will be sent to the \"#{roomname}\""
    else
      say "There is no room defined called \"#{roomname}\""
    end
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end  

  #play movie or episode
  listen_for /play (.+?)(?: in the (.*))?$/i do |title,roomname|
    if (roomname == "" || roomname == nil)
      roomname = @active_room
    else
      roomname = roomname.downcase.strip
    end

    if (@xbmc.connect(roomname))
      if @roomlist.has_key?(roomname)
        @active_room = roomname
      end

      tvshow = @xbmc.find_show(title)
      if (tvshow == "")
        movie = @xbmc.find_movie(title)
        if (movie == "")
          say "Title not found, please try again"
        else
          say "Now playing \"#{movie["title"]}\"", spoken: "Now playing \"#{movie["title"]}\""
          @xbmc.play(movie["file"])
        end
      else  
        episode = @xbmc.find_first_unwatched_episode(tvshow["tvshowid"])
        if (episode == "")
          say "No unwatched episode found for the \"#{tvshow["label"]}\""
        else    
          say "Now playing \"#{episode["title"]}\" (#{episode["showtitle"]}, Season #{episode["season"]}, Episode #{episode["episode"]})", spoken: "Now playing \"#{episode["title"]}\""
          @xbmc.play(episode["file"])
        end
      end
    else 
      say "The XBMC interface is unavailable, please check the plugin configuration or check if XBMC is running"
    end
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end

  
end

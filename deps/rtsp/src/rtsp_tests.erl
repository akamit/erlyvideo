%%% @author     Max Lapshin <max@maxidoors.ru> [http://erlyvideo.org]
%%% @copyright  2010 Max Lapshin
%%% @doc        RTSP decoder module
%%% @end
%%% @reference  See <a href="http://erlyvideo.org/rtsp" target="_top">http://erlyvideo.org</a> for common information.
%%% @end
%%%
%%% This file is part of erlang-rtsp.
%%%
%%% erlang-rtsp is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%%
%%% erlang-rtsp is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with erlang-rtsp.  If not, see <http://www.gnu.org/licenses/>.
%%%
%%%---------------------------------------------------------------------------------------
-module(rtsp_tests).
-author('Max Lapshin <max@maxidoors.ru>').
-include_lib("erlmedia/include/video_frame.hrl").
-compile(export_all).


axis_m1011_test_() ->
  run_camera_test("axis-m1011", 8092).

beward_test_() ->
  run_camera_test("beward", 8092).

sanyo_hd2100_test_() ->
  run_camera_test("sanyo-hd2100", 8092).

run_camera_test(Name, Port) ->
  {spawn, {setup,
    fun() -> _Pid = spawn_link(rtsp_test_client, simulate_camera, [Name, Port]) end,
    fun(Pid) -> erlang:exit(Pid, kill) end,
    [fun() ->
      {ok, _P} = media_provider:play(default, "rtsp://localhost:8092/"++Name, [{retry_limit,0},{clients_timeout,0}]),
      timer:send_after(40000, stop),
      Frames = read_frames([]),
      Delta = (hd(lists:reverse(Frames)))#video_frame.dts - (hd(Frames))#video_frame.dts,
      true = Delta >= 20000
    end]
  }}.


read_frames(Acc) ->
  receive
    #video_frame{} = F -> read_frames([F|Acc]);
    stop -> lists:reverse(Acc)
  after
    1000 -> lists:reverse(Acc)
  end.
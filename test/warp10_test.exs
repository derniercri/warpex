defmodule WarpexTest do
  use ExUnit.Case
  doctest Warpex

  @data """
  1523057810409985// sensor.1.latency{state=unknow,.app=ovh.bggfecgmkkabj} 557
  =1523057750319780// 557
  =1523057554653873// 384
  =1523057494566067// 384
  =1523057108208620// 484
  =1523057048104487// 433
  =1523055809486469// 612
  =1523055749369517// 594
  =1523055595307522// 355
  =1523055535170463// 355
  =1523055413326989// 901
  =1523055353169662// 726
  =1523055292528362// 980
  =1523055232403516// 985
  =1523054801174830// 623
  =1523054741073269// 623
  =1523054659735610// 283
  =1523054599645267// 290
  =1523054488694477// 409
  =1523054428586077// 570
  """

  test "parse response" do
    items = Warpex.parse_result(@data)

    assert List.last(items)["labels"]["state"] == "unknow"
    assert List.last(items)["ts"] == 1_523_054_428_586_077
  end

  # test "request" do
  #  dt = %DateTime{
  #    year: 2000,
  #    month: 2,
  #    day: 29,
  #    zone_abbr: "CET",
  #    hour: 23,
  #    minute: 0,
  #    second: 7,
  #    microsecond: {0, 0},
  #    utc_offset: 3600,
  #    std_offset: 0,
  #    time_zone: "Europe/Warsaw"
  #  }
  #
  #    Warpex.fetch("~metric.1.*{}", dt, dt)
  #  end
end

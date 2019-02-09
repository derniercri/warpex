defmodule WarpexTest do
  use ExUnit.Case
  doctest Warpex

  test "parse response" do
    data = """
    1523057810409985// sensor.1.latency{state=unknow,.app=ovh.bggfecgmkkabj} 557
    =1523054488694477// 409
    =1523054428586077// 570
    """

    items = Warpex.parse_result(data)

    assert List.last(items)["labels"]["state"] == "unknow"
    assert List.last(items)["ts"] == 1_523_054_428_586_077
  end

  test "parse with latlon" do
    data = """
    1521969018757000/50.683299992233515:2.8832999244332314/214748 3.12.6{.app=drew-dev} 36.5
    =1521969018756000// 36.5
    =1521969018755000// 36.5
    =1521969018754000// 36.7
    """

    items = Warpex.parse_result(data)
    assert List.last(items)["ts"] == 1_521_969_018_754_000
    assert List.last(items)["latlon"] == "50.683299992233515:2.8832999244332314"
    assert List.last(items)["value"] == "36.7"
    assert List.last(items)["name"] == "3.12.6"
    assert List.last(items)["elev"] == "214748"
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

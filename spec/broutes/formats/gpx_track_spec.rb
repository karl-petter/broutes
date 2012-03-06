require 'spec_helper'

describe Formats::GpxTrack do
  describe "#load" do
    before(:all) do
      @file = open_file('single_lap_gpx_track.xml')
      @target = Formats::GpxTrack.new
      @route = GeoRoute.new
      
      Formats::GpxTrack.new.load(@file, @route)
    end
      
    it "sets the start point lat" do
      @route.start_point.lat.should eq(52.9552055)
    end
    it "sets the start point lon" do
      @route.start_point.lon.should eq(-1.1558583)
    end
    it "sets the total distance" do
      round_to(@route.total_distance, 3).should eq(7.088)
    end
    it "sets the total ascent" do
      @route.total_ascent.round.should eq(34)
    end
    it "sets the total descent" do
      @route.total_descent.round.should eq(37)
    end
  end
end

require 'spec_helper'

describe GeoRoute do
  describe "#add_point" do
    before(:each) do
      @route = GeoRoute.new
      @lat = random_lat
      @lon = random_lon
      @elevation = 35.6000000
      @new_point = GeoPoint.new(@lat, @lon, @elevation, 0)
    end

    subject { @route.add_point(@lat, @lon, @elevation) }

    context "when route is empty" do

      it "sets the start point to the new_point" do
        subject
        @route.start_point.should eq(@new_point)
      end
      it "should set the total distance to zero" do
        subject
        @route.total_distance.should eq(0)
      end
      it "should add the start point to the points list" do
        subject
        @route.points.first.should eq(@route.start_point)
      end
    end
    context "when route already has a start point" do
      before(:each) do
        @start_point = GeoPoint.new(random_lat, random_lon, random_elevation, 0)
        @route.add_point(@start_point.lat, @start_point.lon, @start_point.elevation)
      end

      it "should not change start_point" do
        subject
        @route.start_point.should eq(@start_point)
      end
      it "should set the total distance to be haversine distance between the start_point and the new point" do
        subject
        @route.total_distance.should eq(Maths.haversine_distance(@start_point, @new_point).round)
      end
      it "set the distance of the point to be the haverside_distance between the start_point" do
        subject
        last(@route.points).distance.should eq(Maths.haversine_distance(@start_point, @new_point))
      end
    end

    context "when route already has at least two points" do
      before(:each) do
        @start_point = GeoPoint.new(random_lat, random_lon, random_elevation)
        @next_point = GeoPoint.new(random_lat, random_lon, random_elevation)
        @route.add_point(@start_point.lat, @start_point.lon, @start_point.elevation)
        @route.add_point(@next_point.lat, @next_point.lon, @next_point.elevation)
      end
      it "should set the total distance to haversine distance along all points" do
        subject
        @route.total_distance.should eq(
          Maths.haversine_distance(@start_point, @next_point).round +
          Maths.haversine_distance(@next_point, @new_point).round
          )
      end
      it "set the distance of the point to haversine distance along all points" do
        subject
        last(@route.points).distance.should eq(
          Maths.haversine_distance(@start_point, @next_point) +
          Maths.haversine_distance(@next_point, @new_point)
          )
      end
    end
  end
  describe "#process_elevation_delta" do
    before(:each) do
      @route = GeoRoute.new
      @next_point = GeoPoint.new(random_lat, random_lon, random_elevation)
    end

    subject { @route.process_elevation_delta(@last_point, @next_point) }

    context "when last_point is nil" do
      it "has an total_ascent of nil" do
        subject
        @route.total_ascent.should eq(0)
      end
      it "has an total_descent of nil" do
        subject
        @route.total_descent.should eq(0)
      end
    end
    context "when last_point is same elevation as next point" do
      before(:each) do
        @last_point = GeoPoint.new(random_lat, random_lon, @next_point.elevation)
      end
      it "has an total_ascent of zero" do
        subject
        @route.total_ascent.should eq(0)
      end
      it "has an total_descent of zero" do
        subject
        @route.total_descent.should eq(0)
      end
    end
    context "when last_point is lower than the next point" do
      before(:each) do
        @delta = random_elevation
        @last_point = GeoPoint.new(random_lat, random_lon, @next_point.elevation - @delta)
      end
      it "the delta is added to the total_ascent" do
        subject
        round_to(@route.total_ascent, 3).should eq(@delta)
      end
      it "has an total_descent of zero" do
        subject
        @route.total_descent.should eq(0)
      end
    end
    context "when last_point is higher than the next point" do
      before(:each) do
        @delta = random_elevation
        @last_point = GeoPoint.new(random_lat, random_lon, @next_point.elevation + @delta)
      end
      it "has an total_ascent of zero" do
        subject
        @route.total_ascent.should eq(0)
      end
      it "the delta is added to the total_descent" do
        subject
        round_to(@route.total_descent, 3).should eq(@delta)
      end
    end
  end
  describe "#hilliness" do
    before(:each) do
      @route = GeoRoute.new
    end

    subject { @route.hilliness }

    context "when 1000 m ascent in 100km" do
      before(:each) do
        @route.stub(:total_distance) { 100000 }
        @route.stub(:total_ascent) { 1000 }
      end
      it "is 10" do
        subject.should eq(10)
      end
    end
    context "when 0 ascent in 100km" do
      before(:each) do
        @route.stub(:total_distance) { 100000 }
        @route.stub(:total_ascent) { 0 }
      end
      it "is 0" do
        subject.should eq(0)
      end
    end
    context "when 1000 ascent in 0km" do
      before(:each) do
        @route.stub(:total_distance) { 0 }
        @route.stub(:total_ascent) { 1000 }
      end
      it "is 0" do
        subject.should eq(0)
      end
    end
  end

end

include PolylineCodec

class EncodeZctaBoundaries < ActiveRecord::Migration
  def self.up
    add_column :zctas, :points, :text
    add_column :zctas, :levels, :text

    # encode polyline
    say_with_time "encoding zcta latlng dataset" do
      Zcta.find( :all ).each do |zcta|
        zip_boundary = []

        zcta.latlongs.each_with_index { |x,n| ( zip_boundary << Point.new( x.lat, x.lng ) ) unless n == 0 }
        
        polyline_encoder = PolylineEncoder.new
        polyline_encoder.dp_encode( zip_boundary )

        zcta.points = polyline_encoder.encoded_points.gsub( "\\", "\\\\\\\\" )
        zcta.levels = polyline_encoder.encoded_levels

        zcta.save!
      end
    end
  end

  def self.down
    drop_column :zctas, :points
    drop_column :zctas, :levels
  end
end

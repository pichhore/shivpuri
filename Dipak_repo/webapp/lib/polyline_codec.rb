module PolylineCodec

  class Point
    attr_accessor :lat, :lng
    def initialize(lat, lng)
      @lat, @lng = lat, lng
    end
  end

  class PolylineEncoder
    attr_reader :encoded_points, :encoded_levels

    def initialize(options = {})
      @zoom_factor = options[:zoom_factor] || 32
      @num_levels = options[:num_levels] || 4
      @very_small = options[:very_small] || 0.00001
      @force_endpoints = options[:force_endpoints] || true
      @zoom_level_breaks = Array.new
      for i in 0 .. @num_levels do
        @zoom_level_breaks[i] = @very_small * (@zoom_factor ** (@num_levels-i-1))
      end
    end

    # douglas-peucker algorithm
    def dp_encode(points)
      abs_max_dist = 0
      stack = Array.new
      dists = Array.new
      max_dist, max_loc, temp, first, last, current = 0

      if points.length > 2
        stack.push([0, points.length-1])
        while stack.length > 0 
          current = stack.pop
          max_dist = 0

          i = current[0]+1
          while i < current[1]
            temp = distance(points[i], 
              points[current[0]], points[current[1]])
            if temp > max_dist
              max_dist = temp
              max_loc = i
              if max_dist > abs_max_dist
                abs_max_dist = max_dist
              end
            end
            i += 1
          end

          if max_dist > @very_small
            dists[max_loc] = max_dist
            stack.push([current[0], max_loc])
            stack.push([max_loc, current[1]])
          end
        end
      end
      @encoded_points = create_encodings(points, dists)
      @encoded_levels = encode_levels(points, dists, abs_max_dist)
    end

    private

    def distance(p0,p1,p2)
      if p1.lat == p2.lat and p1.lng == p2.lng
        out = Math.sqrt(((p2.lat - p0.lat)**2) + ((p2.lng - p0.lng)**2))
      else
        u = ((p0.lat - p1.lat)*(p2.lat - p1.lat)+(p0.lng - p1.lng)*(p2.lng - p1.lng))/
          (((p2.lat - p1.lat)**2) + ((p2.lng - p1.lng)**2))
        if u <= 0
          out = Math.sqrt( ((p0.lat - p1.lat)**2 ) + ((p0.lng - p1.lng)**2) )
        end
        if u >= 1
          out = Math.sqrt(((p0.lat - p2.lat)**2) + ((p0.lng - p2.lng)**2))
        end
        if 0 < u and u < 1
          out = Math.sqrt( ((p0.lat-p1.lat-u*(p2.lat-p1.lat))**2) +
            ((p0.lng-p1.lng-u*(p2.lng-p1.lng))**2) )
        end
      end
      return out
    end

    def create_encodings(points, dists)
      plat = 0
      plng = 0
      encoded_points = ""
       for i in 0 .. points.length do
        if !dists[i].nil? || i == 0 || i == points.length-1 
          point = points[i]
	  if !point.blank?
          lat = point.lat
          lng = point.lng
          late5 = (lat * 1e5).floor
          lnge5 = (lng * 1e5).floor
          dlat = late5 - plat
          dlng = lnge5 - plng
          plat = late5
          plng = lnge5
          encoded_points << encode_signed_number(dlat) + 
            encode_signed_number(dlng)
		end
        end
      end
      return encoded_points
    end

    def compute_level(dd)
      lev = 0
      if dd > @very_small
        while dd < @zoom_level_breaks[lev]
          lev += 1
        end
        return lev
      end
    end

    def encode_levels(points, dists, absMaxDist)
      encoded_levels = ""
      if @force_endpoints
        encoded_levels << encode_number(@num_levels-1)
      else
        encoded_levels << encode_number(@num_levels-compute_level(abs_max_dist)-1)
      end
      for i  in 1 .. points.length-1
        if !dists[i].nil?
          encoded_levels << encode_number(@num_levels-compute_level(dists[i])-1)
        end
      end
      if @force_endpoints
        encoded_levels << encode_number(@num_levels-1)
      else
        encoded_levels << this.encode_number(@num_levels-compute_level(abs_max_dist)-1)
      end
      return encoded_levels
    end

    def encode_number(num)
      encode_string = ""
      while num >= 0x20
        next_value = (0x20 | (num & 0x1f)) + 63
        encode_string << next_value.chr
        num >>= 5
      end
      final_value = num + 63
      encode_string << final_value.chr
      return encode_string
    end

    def encode_signed_number(num)
      sgn_num = num << 1
      if num < 0
        sgn_num = ~(sgn_num)
      end
      return encode_number(sgn_num)
    end
  end

end

class Tile
	attr_accessor :val, :pre, :nex

	def initialize(val)
		@val = val
		@pre = nil
		@nex = nil
	end

	def link(pre, nex)
		@pre = pre
		@nex = nex
	end

	def remove
		@pre.nex = @nex
		@nex.pre = @pre
	end

	def restore
		@nex.pre = self
		@pre.nex = self
	end
end

class Operation
	def initialize(val1, ope, val2, res)
		@val1 = val1
		@ope = ope
		@val2 = val2
		@res = res
	end

	def output
		puts "#{@val1} #{@ope} #{@val2} = #{@res}"
	end
end

class Countdown
	def initialize(vals)
		@tiles = []
		vals.each do |val|
			@tiles.push(Tile.new(val))
		end
		vals_n = vals.size
		@target = @tiles[vals_n-1]
		@tiles[0].link(@target, @tiles[1])
		for i in 1..vals_n-2
			@tiles[i].link(@tiles[i-1], @tiles[i+1])
		end
		@target.link(@tiles[vals_n-2], @tiles[0])
		@operations = []
		@nodes_n = 0
		@solutions_n = 0
		search
		puts "Nodes #{@nodes_n}"
		puts "Solutions #{@solutions_n}"
		STDOUT.flush
	end

	def search
		@nodes_n += 1
		if @target.pre == @target.nex
			if @target.pre.val == @target.val
				@solutions_n += 1
				puts "Solution found"
				@operations.each do |operation|
					operation.output
				end
				STDOUT.flush
			end
			return
		end
		tile1 = @target.nex
		while tile1 != @target
			if is_unique_val?(@target.nex, tile1)
				tile1.remove
				tile2 = tile1.nex
				while tile2 != @target
					if is_unique_val?(tile1.nex, tile2)
						@operations.push(Operation.new(tile1.val, '+', tile2.val, tile1.val+tile2.val))
						val_bak = tile2.val
						tile2.val += tile1.val
						search
						tile2.val = val_bak
						@operations.pop
						if tile1.val*tile2.val != tile1.val+tile2.val
							@operations.push(Operation.new(tile1.val, '*', tile2.val, tile1.val*tile2.val))
							val_bak = tile2.val
							tile2.val *= tile1.val
							search
							tile2.val = val_bak
							@operations.pop
						end
						if tile1.val > tile2.val
							@operations.push(Operation.new(tile1.val, '-', tile2.val, tile1.val-tile2.val))
							val_bak = tile2.val
							tile2.val = tile1.val-tile2.val
							search
							tile2.val = val_bak
							@operations.pop
						end
						if tile2.val > tile1.val
							@operations.push(Operation.new(tile2.val, '-', tile1.val, tile2.val-tile1.val))
							val_bak = tile2.val
							tile2.val -= tile1.val
							search
							tile2.val = val_bak
							@operations.pop
						end
						if tile1.val%tile2.val == 0 && tile1.val/tile2.val != tile1.val*tile2.val && tile1.val/tile2.val != tile1.val-tile2.val && tile1.val/tile2.val != tile2.val-tile1.val
							@operations.push(Operation.new(tile1.val, '/', tile2.val, tile1.val/tile2.val))
							val_bak = tile2.val
							tile2.val = tile1.val/tile2.val
							search
							tile2.val = val_bak
							@operations.pop
						end
						if tile2.val%tile1.val == 0 && tile2.val/tile1.val != tile1.val*tile2.val && tile2.val/tile1.val != tile1.val-tile2.val && tile2.val/tile1.val != tile2.val-tile1.val && (tile1.val%tile2.val != 0 || tile2.val/tile1.val != tile1.val/tile2.val)
							@operations.push(Operation.new(tile2.val, '/', tile1.val, tile2.val/tile1.val))
							val_bak = tile2.val
							tile2.val /= tile1.val
							search
							tile2.val = val_bak
							@operations.pop
						end
					end
					tile2 = tile2.nex
				end
				tile1.restore
			end
			tile1 = tile1.nex
		end
	end

	def is_unique_val?(start, stop)
		tile = start
		while tile != stop
			if tile.val == stop.val
				return false
			end
			tile = tile.nex
		end
		true
	end
end

if ARGV.size < 2
	STDERR.puts "Invalid number of arguments"
	STDERR.flush
	exit false
end
vals = []
ARGV.each do |str|
	if str.to_i.to_s == str && str.to_i > 0
		vals.push(str.to_i)
	else
		STDERR.puts "Invalid argument"
		STDERR.flush
		exit false
	end
end
Countdown.new(vals)

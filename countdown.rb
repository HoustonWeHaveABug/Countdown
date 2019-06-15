class Tile
	attr_reader :idx, :val, :gen
	attr_accessor :pre, :nex

	def set(val, gen)
		@val = val
		@gen = gen
	end

	def initialize(idx, val)
		@idx = idx
		set(val, 0)
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
	attr_reader :gen2, :val_a, :val_b

	def initialize(gen2, val_a, ope, val_b, res)
		@gen2 = gen2
		@val_a = val_a
		@ope = ope
		@val_b = val_b
		@res = res
	end

	def output
		puts "#{@val_a} #{@ope} #{@val_b} = #{@res}"
	end
end

class Countdown
	def initialize(vals)
		tiles = []
		idx = 0
		vals.each do |val|
			tiles.push(Tile.new(idx, val))
			idx += 1
		end
		vals_n = vals.size
		@target = tiles[vals_n-1]
		tiles[0].link(@target, tiles[1])
		for i in 1..vals_n-2
			tiles[i].link(tiles[i-1], tiles[i+1])
		end
		@target.link(tiles[vals_n-2], tiles[0])
		@operations = []
		@nodes_n = 0
		@solutions_n = 0
		search(@target, 0, 1)
		puts "Nodes #{@nodes_n}"
		puts "Solutions #{@solutions_n}"
		STDOUT.flush
	end

	def search(tile1_pre, gen_pre, step)
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
		tile = @target.nex
		ones = 0
		product = 1
		while tile != @target && ones == 0 && product < @target.val
			if tile.val == 1
				ones += 1
			else
				product *= tile.val
			end
			tile = tile.nex
		end
		if ones == 0 && product < @target.val
			return
		end
		tile1 = @target.nex
		while tile1 != @target.pre
			if is_unique_val?(@target.nex, tile1)
				tile1.remove
				tile2 = tile1.nex
				while tile2 != @target
					if is_unique_val?(tile1.nex, tile2)
						gen = [ tile1.gen, tile2.gen ].max
						if (tile1.idx < tile1_pre.idx && gen == gen_pre) || gen > gen_pre
							res_add = tile1.val+tile2.val
							res_mul = tile1.val*tile2.val
							res_sub1 = tile1.val-tile2.val
							res_sub2 = tile2.val-tile1.val
							res_mod1 = tile1.val%tile2.val
							res_div1 = tile1.val/tile2.val
							res_mod2 = tile2.val%tile1.val
							res_div2 = tile2.val/tile1.val
							@operations.push(Operation.new(tile2.gen, tile1.val, '+', tile2.val, res_add))
							tile2.set(res_add, step)
							search(tile1, gen, step+1)
							operation = @operations.pop
							tile2.set(operation.val_b, operation.gen2)
							if res_mul != res_add
								@operations.push(Operation.new(tile2.gen, tile1.val, '*', tile2.val, res_mul))
								tile2.set(res_mul, step)
								search(tile1, gen, step+1)
								operation = @operations.pop
								tile2.set(operation.val_b, operation.gen2)
							end
							if res_sub1 > 0
								@operations.push(Operation.new(tile2.gen, tile1.val, '-', tile2.val, res_sub1))
								tile2.set(res_sub1, step)
								search(tile1, gen, step+1)
								operation = @operations.pop
								tile2.set(operation.val_b, operation.gen2)
							end
							if res_sub2 > 0
								@operations.push(Operation.new(tile2.gen, tile2.val, '-', tile1.val, res_sub2))
								tile2.set(res_sub2, step)
								search(tile1, gen, step+1)
								operation = @operations.pop
								tile2.set(operation.val_a, operation.gen2)
							end
							if res_mod1 == 0 && res_div1 != res_mul && res_div1 != res_sub1 && res_div1 != res_sub2
								@operations.push(Operation.new(tile2.gen, tile1.val, '/', tile2.val, res_div1))
								tile2.set(res_div1, step)
								search(tile1, gen, step+1)
								operation = @operations.pop
								tile2.set(operation.val_b, operation.gen2)
							end
							if res_mod2 == 0 && res_div2 != res_mul && res_div2 != res_sub1 && res_div2 != res_sub2 && (res_mod1 != 0 || res_div2 != res_div1)
								@operations.push(Operation.new(tile2.gen, tile2.val, '/', tile1.val, res_div2))
								tile2.set(res_div2, step)
								search(tile1, gen, step+1)
								operation = @operations.pop
								tile2.set(operation.val_a, operation.gen2)
							end
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

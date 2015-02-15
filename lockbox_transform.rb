class LockboxTransform
    def initialize()
        
    end
    
    def to_hash(data)
        retval = []
        return parse_blocks(data)
    end 
    def parse_blocks(data)
        position=0
        blocks = []        
        count = 0
        while data.length>=position && count <1000
            block, position = parse_block(data,position)
            blocks << block
            count +=1

        end
        if count>=1000
            raise "loop!!! #{position}"
        end

        return blocks
    end

    def is_colon_at_line?(data,position)
        index_of_colon = data.index(/:/,position)
        index_of_newline = data.index(/\n/,position+1)
        index_of_colon!=nil && (index_of_newline==nil || index_of_colon<index_of_newline)
    end

    def is_empty_line?(data, position)
        data[position] == "\n" && data[position-1]=="\n" 
    end

    def parse_block(data, position)
        block = {}
        count = 0

        while position <= data.length  && count <1000
            identifier, position = expect_identifier(data, position)
            value, position = expect_value(data, position)
            block[identifier] = value
            count +=1
            if is_empty_line?(data, position)
                break
            end
        end

        if count>=1000
            raise "loop!!! #{position}"
        end
        return block, position
    end
    def format_error(data,position)
        "at #{data[0..position].lines.length+1} (#{position} of #{data.length})"
    end

    def expect_identifier(data, position)
        index_of_colon = data.index(/:/,position)
        index_of_newline = data.index(/\n/,position+1)
        if index_of_colon==nil
            raise "expected colon #{format_error(data,position)}"
        end
        if index_of_newline !=nil && index_of_newline<index_of_colon
            raise "expected newline to be after colon #{format_error(data,position)}"
        end
        return data[position..index_of_colon-1].strip.to_sym, index_of_colon+1
    end

    def expect_value(data, position)
        val = []
        index_of_newline = data.index(/\n/,position)
        if index_of_newline==nil
            raise "expected newline"
        end
        val << data[position..index_of_newline-1]
        position = index_of_newline
        count = 0
        while (data.length > position && !is_colon_at_line?(data, position)) && count <1000
            index_of_newline = data.index(/\n/,position+1)
            if index_of_newline==nil
                val << data[position..data.length-1]
                position=data.length+1
            else
                val << data[position..index_of_newline-1]
                position = index_of_newline
            end
            count +=1
        end
        if count>=1000
            raise "loop!!!"
        end
        return val.join("").strip, position
    end
end
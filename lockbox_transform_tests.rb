require_relative "lockbox_transform"
require "test/unit"

class LockboxTransformTestWithSimpleSample < Test::Unit::TestCase
    def setup
        @lt = LockboxTransform.new()
        @data = "Title: my bank account\nInformation: line1\nCategory: Bank Account\nNotes: line1\n"
    end
    def test_that_it_understands_sample
        hash = @lt.to_hash(@data)
        expected = [{:Title=> 'my bank account',
            :Information=>"line1",
            :Category=>'Bank Account',
            :Notes=>"line1"
            }
        ]
        assert_equal(expected,hash)
    end
end
class LockboxTransformTestWithDataSample < Test::Unit::TestCase
    def setup
        @lt = LockboxTransform.new()
        @data = File.read(File.join(File.dirname(__FILE__), 'lockbox_data_2013_12_17.txt'))
    end
    def test_that_it_can_read_value
        value,position = @lt.expect_value(@data,35)
        assert_equal "line1\nline2", value
    end
    def test_that_colon_at_line_is_not_missreported
        value = @lt.is_colon_at_line?(@data,42)
        assert_equal false, value
    end
    def test_that_colon_at_lines
        assert_equal true, @lt.is_colon_at_line?(@data,0)
        assert_equal true, @lt.is_colon_at_line?(@data,23)
    end
    def test_that_empty_line_is_empty
        assert_equal true, @lt.is_empty_line?(@data,96)
    end
    
    def test_that_empty_lines_at_lines
        assert_equal false, @lt.is_empty_line?(@data,0)
        assert_equal false, @lt.is_empty_line?(@data,23)
    end
    def test_that_it_can_parse_block_1
        hash,position = @lt.parse_block(@data,0)
        expected = {:Title=> 'my bank Account',
            :Information=>"line1\nline2",
            :Category=>'Bank Account',
            :Notes=>"line1\nline2\nline3"
            }
        assert_equal expected, hash
        assert_equal 96, position
    end
    def test_that_it_can_parse_block_2
        hash,position = @lt.parse_block(@data,96)
        expected = {:Title=>'my secret data',
            :Information=>'line1',
            :Category=>'Other',
            :Notes=>"line1\nline2"
            }
        assert_equal expected, hash
        assert_equal 173, position
    end
    def test_that_it_can_parse_block_3
        hash,position = @lt.parse_block(@data,173)
        expected = {:Title=>"another secret data",
            :Information=>"line1\nline2",
            :Category=>"Other",
            :Notes=>""
            }
        assert_equal expected, hash
        assert_equal 252, position
    end
    def test_that_it_understands_sample
        hash = @lt.to_hash(@data)
        expected = [{:Title=> 'my bank Account',
            :Information=>"line1\nline2",
            :Category=>'Bank Account',
            :Notes=>"line1\nline2\nline3"
            },
            {:Title=>'my secret data',
            :Information=>'line1',
            :Category=>'Other',
            :Notes=>"line1\nline2"
            },
            {:Title=>"another secret data",
            :Information=>"line1\nline2",
            :Category=>"Other",
            :Notes=>""
            } 
        ]
        assert_equal(expected,hash)
    end
end

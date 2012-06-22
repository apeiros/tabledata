# encoding: utf-8

# Encoding::Windows_1252
# Encoding::MacRoman
# Encoding::UTF_8
# Encoding::ISO8859_15

require 'tables/exceptions'

module Tables
  module Detection
    UnlikelyCharsWin1252    = "\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD" \
                              "\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB" \
                              "\xBC\xBD\xBE\xBF\xD7\xF7"
    UnlikelyCharsIso8859_1  = ""
    UnlikelyCharsMacRoman   = ""

    UmlautsMac  = "äöü".encode(Encoding::MacRoman).force_encoding(Encoding::BINARY)
    UmlautsWin  = "äöü".encode(Encoding::Windows_1252).force_encoding(Encoding::BINARY)

    DiacritsMac = "âàéèô".encode(Encoding::MacRoman).force_encoding(Encoding::BINARY)
    DiacritsWin = "âàéèô".encode(Encoding::Windows_1252).force_encoding(Encoding::BINARY)

  module_function
    def force_guessed_encoding!(string)
      return string if string.force_encoding(Encoding::UTF_8).valid_encoding?
      string.force_encoding(Encoding::BINARY)

      # check for non-mapped codepoints
      possible_encodings = [Encoding::Windows_1252, Encoding::ISO8859_15, Encoding::MacRoman]
      possible_encodings.delete(Encoding::ISO8859_15) if string =~ /[\x80-\x9f]/n
      possible_encodings.delete(Encoding::Windows_1252) if string =~ /[\x81\x8D\x8F\x90\x9D]/n
      return string.force_encoding(possible_encodings.first) if possible_encodings.size == 1

      # # check for occurrences of characters with weighted expectancy
      # # e.g. a "§" is quite unlikely
      # win = string[0,10_000].count(UnlikelyCharsWin1252)
      # iso = string[0,10_000].count(UnlikelyCharsIso8859_1)
      # mac = string[0,10_000].count(UnlikelyCharsMacRoman)

      # Check occurrences of äöü
      case string[0,10_000].count(UmlautsMac) <=> string[0,10_000].count(UmlautsWin)
        when -1 then return string.force_encoding(Encoding::Windows_1252)
        when  1 then return string.force_encoding(Encoding::MacRoman)
      end

      # Check occurrences of âàéèô
      case string[0,10_000].count(DiacritsMac) <=> string[0,10_000].count(DiacritsWin)
        when -1 then return string.force_encoding(Encoding::Windows_1252)
        when  1 then return string.force_encoding(Encoding::MacRoman)
      end

      # Bias for Windows_1252
      string.force_encoding(Encoding::Windows_1252)
    end

    def guess_encoding(string)
      force_guessed_encoding!(string.dup).encoding
    end

    def guess_csv_delimiter(csv, out_of=[',',';'])
      out_of = out_of.map { |delimiter| delimiter.encode(csv.encoding) }

      out_of.max_by { |delimiter| csv[0, 10_000].count(delimiter) }
    end

    def file_type_from_path(path)
      case path
        when /\.csv$/ then :csv
        when /\.xls$/ then :xls
        when /\.xlsx$/ then :xlsx
        else raise InvalidFileType, "Unknown file format for path #{path.inspect}"
      end
    end
  end
end

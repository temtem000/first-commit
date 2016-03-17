require 'RMagick'

class ColorIdentification
  # 画像ファイル
  IMG_FILE = "IMG_FILE.jpg"
  # この百分率未満は非表示
  RATE_MIN = 0.05

  def initialize
    # 配列の先頭画像を取得する。
    @img = Magick::Image.read(IMG_FILE).first


    # ピクセル数
    @px_x = @img.columns       # 横
    @px_y = @img.rows          # 縦
    @px_total = @px_x * @px_y  # トータル
  end

  # 使用色集計
  def compile
    begin
      # 画像の Depth を取得
      img_depth = @img.depth

      # カラーヒストグラムを取得してハッシュで集計
      hist = @img.color_histogram.inject({}) do |hash, key_val|
        # 各ピクセルの色を16進で取得
        color = key_val[0].to_color(Magick::AllCompliance, false, img_depth, true)
        # Hash に格納
        hash[color] ||= 0
        hash[color] += key_val[1]
        hash
      end

      # ヒストブラムのハッシュを値の大きい順にソート
      @hist = hist.sort{|a, b| b[1] <=> a[1]}
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.compile] #{e}"
      exit 1
    end
  end

  # 結果表示
  def display
    begin
      @hist.each do |color, count|
        rate = (count / @px_total.to_f) * 100
        break if rate < RATE_MIN
        puts "#{color} => #{count} px ( #{sprintf("%2.4f", rate)} % )"
      end
      puts
      puts "Image Size: #{@px_x} px * #{@px_y} px"
      puts "TOTAL     : #{@px_total} px, #{@hist.size} colors"
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.display] #{e}"
      exit 1
    end
  end
end

# 画像内使用色集計
obj_main = ColorIdentification.new
obj_main.compile
obj_main.display

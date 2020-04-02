require 'pycall/import'
# require 'numpy'

include PyCall::Import

pyimport 'cv2'
pyimport 'numpy', as: 'np'

def detect_red_color(image)
  # HSV色空間に変換
  hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

  # 赤色(値域1)を抽出
  hsv_min = np.array([0, 45, 0])
  hsv_max = np.array([0, 75, 255])
  mask1 = cv2.inRange(hsv, hsv_min, hsv_max)

  # 赤色(値域2)を抽出
  hsv_min = np.array([150, 30, 0])
  hsv_max = np.array([255, 255, 255])
  mask2 = cv2.inRange(hsv, hsv_min, hsv_max)

  mask = mask1 + mask2

  # マスキング処理
  cv2.bitwise_and(gray, mask)
end

def detect_green_color(image)
  # HSV色空間に変換
  hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

  # 緑色を抽出
  hsv_min = np.array([45, 45, 0])
  hsv_max = np.array([60,255,255])
  mask = cv2.inRange(hsv, hsv_min, hsv_max)

  # マスキング処理
  cv2.bitwise_and(gray, mask)
end


# 画像を読み込む
input_filename = 'images/hotel.JPG'

image = cv2.imread(input_filename)
return unless image

# 色検出
red_masked_image    = detect_red_color image
green_masked_image  = detect_green_color image
masked_image        = red_masked_image + green_masked_image

# cv2.imwrite('masked_image.png', masked_image)

# コーナー検出
corners = cv2.goodFeaturesToTrack(masked_image, 25, 0.01, 10)
corners = np.array(corners)
# corners = Numpy.array(corners)

font = cv2.FONT_HERSHEY_SIMPLEX
red = PyCall.eval('(0, 0, 200)')
black = PyCall.eval('(0, 0, 0)')

# Numpy::NDArray には each メソッドがない
(0...corners.size).each do |i|
  point = corners[i][0] rescue break
  x, y = point[0].to_i, point[1].to_i
  center = PyCall.eval("(#{x}, #{y})")
  text_point = PyCall.eval("(#{x - 20}, #{y - 5})")

  cv2.circle(image, center, 5, red, thickness=1, lineType=cv2.LINE_AA)
  cv2.putText(image, "#{x}:#{y}", text_point, font, 0.3, black, 1, cv2.LINE_AA)
end

# 加工した画像を保存
cv2.imwrite('image.png', image)

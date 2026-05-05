use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

driving-data = load-spreadsheet("https://docs.google.com/spreadsheets/d/1G6zAS1QS7OTRLaLMCm3yO_ug45VJJNxAK8_uTyY1sYo/")

training = 
  load-table: id, curve-sharpness, speed, offset, steering-angle
    source: driving-data.sheet-by-name("training", true)
  end

# Once you have a function that predicts the 
# steering angle, you can use it to run the
# driving simulation!

# fun predictor(r): r["speed"] * 0.1 end
# drive(predictor)
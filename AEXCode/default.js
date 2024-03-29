configuration = {
  "width": 1920,
  "height": 1080,
//  "fps": 60
}

var layer1 = new Layer({
  "x": 500,
  "y": 500,
  "width": 150,
  "height": 150,
  "backgroundColor": WHITE
})

var layer2 = new Layer({
  "x": 100,
  "y": 100,
  "width": 100,
  "height": 100,
  "backgroundColor": WHITE
})

var backgroundSolid = new Layer({
  "x": 200,
  "y": 200,
  "width": 100,
  "height": 100
})

layers = [backgroundSolid, layer1, layer2]

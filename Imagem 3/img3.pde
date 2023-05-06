void setup() {
  size(1770, 890);
  noLoop();
}

void draw() {
  PImage img = loadImage("img3.png");
  PImage imgMask = loadImage("img3 - mask.png");
  PImage aux = loadImage("img3.png");
  PImage segmentedImg = createImage(img.width, img.height, RGB);

  color[] colors = new color[] {
    color(255, 0, 0), color(0, 255, 0), color(0, 0, 255)
  };

  aux = segmentImage(aux, colors);
  verificarPixel(imgMask, aux);
  segmentedImg = mergeImageWithGroundTruth(aux, segmentedImg, img);

  image(img, 0, 0);
  image(aux, aux.width + 10, 0);
  image(segmentedImg, segmentedImg.width * 2 + 20, 0);
  image(imgMask, 0, img.height + 10);

  save("result.png");
}

PImage segmentImage(PImage img, color[] colors) {
  PImage segmentedImg = createImage(img.width, img.height, RGB);

  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      color c = img.get(x, y);
      c = color(red(c), green(c), blue(c));
      color closestColor = colors[0];
      float closestDist = dist(red(c), green(c), blue(c), red(closestColor), green(closestColor), blue(closestColor));
      for (int i = 1; i < colors.length; i++) {
        float d = dist(red(c), green(c), blue(c), red(colors[i]), green(colors[i]), blue(colors[i]));
        if (d < closestDist) {
          closestColor = colors[i];
          closestDist = d;
        }
      }
      segmentedImg.set(x, y, color(red(closestColor), green(closestColor), blue(closestColor)));
    }
  }

  for (int y = 0; y < segmentedImg.height; y++) {
    for (int x = 0; x < segmentedImg.width; x++) {
      int pos = (y) * segmentedImg.width + (x);

      if (red(segmentedImg.pixels[pos]) > 50 && x > 135 && x < 505 && y < 355 && y > 60) {
        segmentedImg.pixels[pos] = color(255);
      } else {
        segmentedImg.pixels[pos] = color(0);
      }
    }
  }

  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      int pos = y * img.width + x;
      color c = segmentedImg.pixels[pos];
      if (((x - 480) * (x - 480)) / (90 * 90) + ((y - 90) * (y - 90)) / (65 * 65) <= 1) {
        segmentedImg.pixels[pos] = color(0);
      } else if (((x - 111) * (x - 111)) / (130 * 130) + ((y - 340) * (y - 340)) / (65 * 65) <= 1) {
        segmentedImg.pixels[pos] = color(0);
      } else {
        segmentedImg.pixels[pos] = c;
      }
    }
  }

  segmentedImg.updatePixels();

  return segmentedImg;
}

void verificarPixel(PImage originalImage, PImage newImage) {
  int count = 0;
  int falseNegative = 0, falsePositive = 0, truth = 0;
  float percentFN = 0, percentFP = 0, percentV = 0;

  if (originalImage.height == newImage.height && originalImage.width == newImage.width) {

    println("IMAGENS DE DIMENSÕES IGUAIS");
    int posO, posN;
    int pAuxO, pAuxN;

    for (int y = 0; y < originalImage.height; y++) {
      for (int x = 0; x < originalImage.width; x++) {
        count++;
        posO = (y) * originalImage.width + (x);
        posN = (y) * newImage.width + (x);
        pAuxO = parseInt(blue(originalImage.pixels[posO]));
        pAuxN = parseInt(blue(newImage.pixels[posN]));

        if (pAuxO == 255 && pAuxN == 0) {
          falseNegative++;
        } else if (pAuxO == 0 && pAuxN == 255) {
          falsePositive++;
        } else {
          truth++;
        }
      }
    }
  } else {
    println("IMAGENS DE DIMENSÕES DIFERENTES");
  }

  float falsoN1 = falseNegative * 100;
  percentFN = falsoN1 / count;
  println("\nFalso Negativo \n Quantidade:" + falseNegative + " \n Porcentagem:" + percentFN + "\n(" + falseNegative + " x " + 100 + ")/" + count + " = " + percentFN);

  float falsoP1 = falsePositive * 100;
  percentFP = falsoP1 / count;
  println("\nFalso Positivo \n Quantidade:" + falsePositive + " \n Porcentagem:" + percentFP + "\n(" + falsePositive + " x " + 100 + ")/" + count + " = " + percentFP);

  float percentV1 = truth * 100;
  percentV = percentV1 / count;
  println("\nVerdadeiro \n Quantidade:" + truth + " \n Porcentagem:" + percentV + "\n(" + truth + " x " + 100 + ")/" + count + " = " + percentV);
}

PImage mergeImageWithGroundTruth(PImage groundTruthImg, PImage mergeImg, PImage originalImage) {
  for (int y = 0; y < groundTruthImg.height; y++) {
    for (int x = 0; x < groundTruthImg.width; x++) {
      int pos = (y) * groundTruthImg.width + (x);

      if (red(groundTruthImg.pixels[pos]) > 0) {
        mergeImg.pixels[pos] = originalImage.pixels[pos];
      }
    }
  }

  return mergeImg;
}

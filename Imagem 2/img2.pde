void setup() {
  size(1770, 890);
  noLoop();
}

void draw() {
  PImage img = loadImage("img2.png");
  PImage imgMask = loadImage("img2 - mask.png");
  PImage aux = loadImage("img2.png");
  PImage aux2 = createImage(img.width, img.height, RGB);

  aux = thresholding(aux);
  verificarPixel(imgMask, aux);
  aux2 = mergeImageWithGroundTruth(aux, aux2, img);

  image(img, 0, 0);
  image(aux, aux.width + 10, 0);
  image(aux2, aux2.width * 2 + 20, 0);
  image(imgMask, 0, img.height + 10);

  save("result.png");
}

PImage thresholding(PImage aux2) {
  for (int y = 0; y < aux2.height; y++) {
    for (int x = 0; x < aux2.width; x++) {
      int pos = (y) * aux2.width + (x);

      if (blue(aux2.pixels[pos]) < 50 && x > 5 && x < 535 && y > 115 && y < 315 || red(aux2.pixels[pos]) > 100 && x > 5 && x < 535 && y > 115 && y < 315 || green(aux2.pixels[pos]) > 90 && x > 5 && x < 535 && y > 115 && y < 315) {
        aux2.pixels[pos] = color(255);
      } else {
        aux2.pixels[pos] = color(0);
      }
    }
  }

  return aux2;
}

PImage escalaDeCinza(PImage aux2) {
  for (int y = 0; y < aux2.height; y++) {
    for (int x = 0; x < aux2.width; x++) {

      int pos = (y) * aux2.width + (x);
      float media = blue(aux2.pixels[pos]);
      aux2.pixels[pos] = color(media);
    }
  }

  return aux2;
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

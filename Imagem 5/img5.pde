void setup() {
  size(1770, 890);
  noLoop();
}

void draw() {
  PImage img = loadImage("img5.png"); // Carrega a variável que armazena a imagem original
  PImage imgMask = loadImage("img5 - mask.png");
  PImage aux = loadImage("img5.png");
  PImage segmentedImg = createImage(img.width, img.height, RGB); // Cria uma nova imagem para a segmentação

  // Aplica o filtro BLUR na imagem original 

  aux = filters(aux);
  verificarPixel(imgMask, aux);
  segmentedImg = mergeImageWithGroundTruth(aux, segmentedImg, img);

  image(img, 0, 0);
  image(aux, aux.width + 10, 0);
  image(segmentedImg, segmentedImg.width * 2 + 20, 0);
  image(imgMask, 0, img.height + 10); // Exibe a imagem segmentada

  save("result.png"); // Salva a imagem segmentada com o nome "segmentedImg.png"
}

PImage filters(PImage aux2) {
  aux2.filter(BLUR);

  // Percorre todos os pixels da imagem e verifica se o valor do canal vermelho é maior do que o canal verde e o azul
  for (int y = 0; y < aux2.height; y++) {
    for (int x = 0; x < aux2.width; x++) {
      int pos = y * aux2.width + x;
      if (red(aux2.pixels[pos]) > green(aux2.pixels[pos]) && red(aux2.pixels[pos]) > blue(aux2.pixels[pos])) {
        // Se a condição for verdadeira, pinta o pixel na imagem segmentada de branco, caso contrário, pinta de preto
        aux2.pixels[pos] = color(255);
      } else {
        aux2.pixels[pos] = color(0);
      }
    }
  }

  // Pinta os pixels de cima para baixo em um terço da altura da imagem de preto
  for (int y = 0; y < aux2.height / 5; y++) {
    for (int x = 0; x < aux2.width; x++) {
      int pos = y * aux2.width + x;
      aux2.pixels[pos] = color(0);
    }
  }

  // Pinta os pixels de baixo para cima em um quinto da altura da imagem de preto
  for (int y = aux2.height - 1; y > aux2.height * 4 / 5; y--) {
    for (int x = 0; x < aux2.width; x++) {
      int pos = y * aux2.width + x;
      aux2.pixels[pos] = color(0);
    }
  }

  aux2.updatePixels(); // Atualiza os pixels da imagem segmentada

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

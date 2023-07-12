import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer audioPlayer;
String message = "";
FFT fft;
float[] waveform;
boolean play;
PImage img;
PFont unicodeFont;

void setup() {
  size(1280, 720);
  background(132, 133, 135);
  img = loadImage("data/pause-play-button.png");
  minim = new Minim(this);
  play = false;
  unicodeFont = createFont("Arial Unicode MS", 30); // use unicode in order to print unicode characters
  textFont(unicodeFont);
  selectInput("Select a sound file:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    message = ("Oops...No file was selected");
  } else {
    String fileName = selection.getName();
    String fileExtension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();
    if (fileExtension.equals("wav") || fileExtension.equals("aiff") || fileExtension.equals("au") ||
        fileExtension.equals("midi") || fileExtension.equals("rmf") || fileExtension.equals("mp3")) {
      audioPlayer = minim.loadFile(selection.getAbsolutePath(), 1024); // smaller buffer size results in lower latency but requires higher computing power
      if (audioPlayer != null) {
        message = "Now playing: " + selection.getName();
        audioPlayer.loop();
        fft = new FFT(audioPlayer.bufferSize(), audioPlayer.sampleRate());
        waveform = new float[audioPlayer.bufferSize()];
        play = true;
      } else {
        message = "X _ X\nUnknown Error";
      }
    } else {
      message = ("Oops...\nUnsupported file format\nOnly .wav, .mp3, .aiff, .au, .midi, .rmf are supported");
    }
  }
}

void draw() {
  background(132, 133, 135);
  fill(255);
  textSize(30); 
  textAlign(CENTER);
  text(message, width / 2, height / 2);
  
  if (audioPlayer != null) {
    background(132, 133, 135);
    image(img, 605, 590, 70, 70); // play/pause button
    
    fft.forward(audioPlayer.mix); // amplitude info
    for (int i = 0; i < audioPlayer.bufferSize(); i++) {
      waveform[i] = audioPlayer.mix.get(i); // wave form info
    }
    noFill();
    if (play == true) {
      stroke(random(255), random(255), random(255));
    } else {
      stroke(255);
    }
    beginShape();
    for (int i = 0; i < waveform.length; i++) {
      float x = map(i, 0, waveform.length, 0, width);
      float y = map(waveform[i], -1, 1, height, 0);
      vertex(x, y);
    }
    endShape();
    
    fill(255);
    textAlign(CENTER);
    text(message, 640, 700);
  }
}

boolean overButton(int x, int y, int radius) {
  if ((mouseX - x) * (mouseX - x) + (mouseY - y) * (mouseY - y) <= radius * radius) {
    return true;
  } else {
    return false;
  }
}

void mouseClicked() {
  if (audioPlayer != null) {
    if (overButton(640, 625, 35)) {
      if (audioPlayer.isPlaying()) {
        audioPlayer.pause();
        play = false;
      } else {
        audioPlayer.play();
        play = true;
      }  
    }
  }
}

void stop() {
  audioPlayer.close();
  minim.stop();
  super.stop();
}

const audioPlayer = new Howl({ src: ["sound.mp3"] });

window.addEventListener("message", (event) => {
  if (event.data.sound) {
    audioPlayer.play();
  }
});

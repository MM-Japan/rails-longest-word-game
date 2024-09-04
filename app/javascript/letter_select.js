function initializeLetterSelection() {
  const letterItems = document.querySelectorAll('.letter-item');
  const guessInput = document.getElementById('guess-input');
  let selectedLetters = []; // Array to track selected letters with their positions

  // Handle clicks on letter items
  letterItems.forEach((item, index) => {
    item.dataset.index = index;

    item.addEventListener('click', function () {
      const letter = item.dataset.letter;
      const letterKey = `${letter}-${index}`;

      if (selectedLetters.includes(letterKey)) {
        selectedLetters = selectedLetters.filter(key => key !== letterKey);
        updateGuessInput();
        item.classList.remove('selected');
      } else {
        selectedLetters.push(letterKey);
        updateGuessInput();
        item.classList.add('selected');
      }
    });
  });

  // Allow typing in the input field
  guessInput.addEventListener('input', function () {
    // No additional logic here for now, just ensuring the field can be typed in
  });

  function updateGuessInput() {
    guessInput.value = selectedLetters.map(key => key.split('-')[0]).join('');
  }
}

document.addEventListener('DOMContentLoaded', initializeLetterSelection);

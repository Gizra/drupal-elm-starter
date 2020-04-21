<?php

use Lurker\Event\FilesystemEvent;
use Robo\Tasks;
use Symfony\Component\EventDispatcher\Event;

/**
 * Theme compilation Robo file.
 */
class RoboFile extends Tasks {

  const OPTIMIZED_FORMATTER = 'Leafo\ScssPhp\Formatter\Crunched';

  const DEV_FORMATTER = 'Leafo\ScssPhp\Formatter\Expanded';

  const THEME_BASE = 'web/themes/custom/theme_server';

  const CSS_DIR_INIT_CMD = 'mkdir '. self::THEME_BASE . '/css';

  /**
   * Compile the app; On success ...
   *
   * @param bool $optimize
   *   Indicate whether to optimize during compilation.
   */
  private function compileTheme_($optimize = FALSE) {
    // Stylesheets.
    $formatter = self::DEV_FORMATTER;
    if ($optimize) {
      $formatter = self::OPTIMIZED_FORMATTER;
    }

    $this->_exec(self::CSS_DIR_INIT_CMD);
    $result = $this->taskScss([
      self::THEME_BASE . '/scss/style.scss' => self::THEME_BASE . '/css/style.css',
    ])
      ->setFormatter($formatter)
      ->importDir(['scss'])
      ->run();

    if ($result->getExitCode() !== 0) {
      $this->taskCleanDir(['css']);
      return $result;
    }

    // Images.

    // Copy everything first.
    $this->_copyDir(self::THEME_BASE . '/assets/images', self::THEME_BASE .  '/dist/images');

    if ($optimize) {
      // Then for the formats where we can optimize, perform it.
      $this->taskImageMinify(self::THEME_BASE . '/assets/images/*.jpg')
        ->to(self::THEME_BASE . '/dist/images/')
        ->run();
      $this->taskImageMinify(self::THEME_BASE . '/assets/images/*.png')
        ->to(self::THEME_BASE . '/dist/images/')
        ->run();
    }
  }

  /**
   * Compile the theme (optimized).
   */
  function compileTheme() {
    $this->say('Compiling (optimized).');
    $this->compileTheme_(TRUE);
  }

  /**
   * Compile the theme.
   *
   * Non-optimized.
   */
  function compileThemeDebug() {
    $this->say('Compiling (non-optimized).');
    $this->compileTheme_();
  }

  /**
   * Watch the theme and compile on change (optimized).
   */
  function watchTheme() {
    $this->say('Compiling and watching (optimized).');
    $this->compileTheme_(TRUE);
    $this->taskWatch()
      ->monitor(
        self::THEME_BASE,
        function (Event $event) {
          $this->compileTheme_(TRUE);
        },
        FilesystemEvent::ALL
      )->run();
  }

  /**
   * Watch the theme path and compile on change.
   *
   * Non-optimized, for `Debug.toString`.
   */
  function watchThemeDebug() {
    $this->say('Compiling and watching (non-optimized).');
    $this->compileTheme_();
    $this->taskWatch()
      ->monitor(
        self::THEME_BASE,
        function (Event $event) {
          $this->compileTheme_();
        },
        FilesystemEvent::ALL
      )->run();
  }

}

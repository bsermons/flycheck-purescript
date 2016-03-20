# flycheck-purescript
Flycheck support for the purescript language

## Usage
``` elisp
  (eval-after-load 'flycheck
    '(add-hook 'flycheck-mode-hook #'flycheck-purescript-setup))
```

Also, somewhere you will need to set the `default-directory` to be the project root. 
Something equivalent to the following:

``` elisp
(add-hook 'purescript-mode-hook
          (lambda ()
            (setq default-directory
                  (locate-dominating-file default-directory "bower.json"))))
```

## Customizable Variables
### flycheck-purescript-reporting-mode
    Determines the general class of errors to show. Can be `all` (default), `errors-only`, or `warn-after-errrors`.
    The last will show warnings only when no errors have been detected.
    
### flycheck-purescript-ignored-error-codes
    List of specific error codes to ignore by flycheck.
    
### flycheck-purescript-compiler-options
    List of compiler options to send to psc.  Default is to turn off all opmizations.

### flycheck-purescript-glob-patterns
    List of globs to send the compiler.
    

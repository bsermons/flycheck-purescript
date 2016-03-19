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
    Determines the general class of errors to show. Can be `all`, `errors-only`, or `warn-after-errrors`.
    The last will show warnings only when no errors have been detected.
    
### flycheck-purescript-ignored-error-codes
    This takes a list of specific error codes to ignore by flycheck.


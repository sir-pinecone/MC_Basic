Add it to your project's modules folder, e.g. `my_cool_project/modules/MC_Basic`

Then import it `#import "MC_Basic"()(DEVELOPER=true, SHOW_CODE_IN_STACK_TRACE=true, xexit=xexit);`

My xexit function looks like this (if you leave out the xexit arg then it'll default to using `exit()`):

```jai
xexit :: (status: s32) {
    print("Shutting down...\n");
    #if OS == .WINDOWS {
        FlushFileBuffers(console_stdout);
    }
    on_shutdown_app();
    exit(status);
}
```

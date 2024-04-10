package glfw

/*
#cgo CFLAGS: -x objective-c -DGL_SILENCE_DEPRECATION
#cgo LDFLAGS: -framework Cocoa -framework OpenGL
#import <Carbon/Carbon.h> // for HIToolbox/Events.h
#import <Cocoa/Cocoa.h>
#include <pthread.h>

void forwardLoadMessage(char **, int len);
*/
import "C"
import (
	"unsafe"
)

var lmc chan (string)

func setLoadMessageChannel(l chan (string)) {
	lmc = l
}

//export forwardLoadMessage
func forwardLoadMessage(files **C.char, len C.int) {
	// https://stackoverflow.com/questions/62012070/convert-array-of-strings-from-cgo-in-go
	for _, s := range (*[1 << 28]*C.char)(unsafe.Pointer(files))[:len:len] {
		lmc <- C.GoString(s)
	}
}

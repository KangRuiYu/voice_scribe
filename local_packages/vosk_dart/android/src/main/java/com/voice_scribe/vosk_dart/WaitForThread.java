package com.voice_scribe.vosk_dart;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.TimeUnit;

// Given to thread to hang it until the given thread finishes all its tasks.
//
// Typically used to prevent data from being used in multiple threads at a time.
class WaitForThread implements Runnable {
    private final ExecutorService executorService;

    public WaitForThread(ExecutorService executorService) {
        this.executorService = executorService;
    }

    @Override
    public void run() {
        try {
            executorService.awaitTermination(Long.MAX_VALUE, TimeUnit.DAYS);
        }
        catch (InterruptedException e) {
        }
    }
}
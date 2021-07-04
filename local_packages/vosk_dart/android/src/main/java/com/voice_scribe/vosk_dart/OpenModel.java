package com.voice_scribe.vosk_dart;

import java.util.concurrent.Callable;

import org.vosk.Model;

// A task that is given to a thread. It opens a model at the given path,
// returning a future of the model.
class OpenModel implements Callable<Model> {
    private final String modelPath;

    public OpenModel(String modelPath) {
        this.modelPath = modelPath;
    }

    public Model call() {
        return new Model(modelPath);
    }
}

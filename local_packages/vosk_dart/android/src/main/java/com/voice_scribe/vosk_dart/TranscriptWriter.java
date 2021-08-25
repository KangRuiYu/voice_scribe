package com.voice_scribe.vosk_dart;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

// Abstracts the parsing and writing of transcription results to a single file.
class TranscriptWriter {
    private final PrintWriter output;

    private boolean writtenFirstResult = false; // Used to treat first results in a special manner.

    // If the given transcriptPath points to a file that does not exists or that cannot be created,
    // a FileNotFoundException is thrown.
    // If the given encoding is unsupported, an UnsupportedEncodingException is thrown.
    public TranscriptWriter(
            String transcriptPath, String encoding
    ) throws FileNotFoundException, UnsupportedEncodingException {
        this.output = new PrintWriter(transcriptPath, encoding);
    }

    // Closes the writer.
    public void close() {
        output.close();
    }

    // Writes the given result to the transcript.
    // If the resultString has no data, then nothing happens.
    // If given string is not a proper JSON string, a JSONException is thrown.
    public void writeResult(JSONObject result) throws JSONException {
        String parsedResult = parseResult(result);

        if (parsedResult.isEmpty()) {
            return;
        }

        if (writtenFirstResult) { // Create separation from previous result only if not first.
            output.write("\n");
        }
        else {
            writtenFirstResult = true;
        }

        output.write(parsedResult);
    }

    // Parses the given result into the proper format.
    // If the result is empty, an empty string is returned.
    // If given string is not a proper JSON string, a JSONException is thrown.
    private static String parseResult(JSONObject result) throws JSONException {
        if (!result.has("result")) { // Terminate if result is empty.
            return "";
        }

        JSONArray wordResults = result.getJSONArray("result");
        String parsedResult = "";

        for (int i = 0; i < wordResults.length(); i++) {
            parsedResult += parseWordResult(wordResults.getJSONObject(i)) + '\n';
        }

        return parsedResult;
    }

    // Parses and returns the given word result JSON object as a formatted string.
    // If the given wordResult does not contain the proper data, a JSONException is thrown.
    private static String parseWordResult(JSONObject wordResult) throws JSONException {
        return wordResult.getString("word") + " " +
                String.valueOf(wordResult.getDouble("start")) + " " +
                String.valueOf(wordResult.getDouble("end")) + " " +
                String.valueOf(wordResult.getDouble("conf"));
    }
}

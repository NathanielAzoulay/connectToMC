public with sharing class SubstringMessage {
    public String extractedError { get; private set; }

    public SubstringMessage(string responseXml, string startTagError, String endTagError) {
        Integer startIndexError = responseXml.indexOf(startTagError);
        Integer endIndexError = responseXml.indexOf(endTagError, startIndexError);
        
        if (startIndexError >= 0 && endIndexError >= 0) {
            extractedError = responseXml.substring(startIndexError + startTagError.length(), endIndexError).trim();
        } else {
            // Gérez le cas où les balises de début ou de fin n'ont pas été trouvées
            extractedError = null;
        }
    }
}
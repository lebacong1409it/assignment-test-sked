@RestResource(urlMapping='/update-contacts/*')
global with sharing class UpdateContactRestAPI {
    @HttpPut
    global static void doPut() {
        Response response = new Response();

        try {
            List<Contact> listContact = new List<Contact>();
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            List<Object> data = (List<Object>) params.get('contacts');
            for (Object item : data) {
                listContact.add((Contact) JSON.deserializeStrict(JSON.serialize(item), Contact.class));
            }

            update listContact;

            response.statusCode = 200;
            response.success = true;
            response.message = 'Update successfully!!!';
            
        } catch (DmlException error) {
            response.statusCode = 422;
            response.success = false;
            response.message = 'Update failure!!!';
            response.error = error.getMessage();

        } catch (Exception error) {
            response.statusCode = 500;
            response.success = false;
            response.message = 'Internal Server Error';
            response.error = error.getMessage();

        }

        response.send();
    }

    class Response {
        public Integer statusCode;
        public Boolean success;
        public String error;
        public String message;

        public Response() {
            this.statusCode = 200;
            this.success = true;
            this.message = '';
            this.error = '';
        }

        public void send() {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statuscode = this.statusCode;
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(this));
        }
    }
}
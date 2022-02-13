#!/usr/bin/env ruby
# JotForm API - Ruby Client
# @copyright   2022 Jotform, Inc.
# @link        https://www.jotform.com
# @version     1.0

require "net/http"
require "uri"
require "rubygems"
require "json"

class JotForm
    attr_accessor :apiKey
    attr_accessor :baseURL
    attr_accessor :apiVersion

    # Create the object
    def initialize(apiKey = nil, baseURL = "https://api.jotform.com", apiVersion = "v1")
        @apiKey = apiKey
        @baseURL = baseURL
        @apiVersion = apiVersion
    end

    def _executeHTTPRequest(endpoint, parameters = nil, type = "GET")
        url = [@baseURL, @apiVersion, endpoint].join("/")
        url = URI.parse(url)
        path = url.path + '?apiKey=' + @apiKey

        if type == "GET"
            request = Net::HTTP::Get.new(path)
        elsif type == "POST"
            request = Net::HTTP::Post.new(path)
            request.set_form_data(parameters)
        elsif type == "DELETE"
            request = Net::HTTP::Delete.new(path)
        elsif type == "PUT"
            request = Net::HTTP::Put.new(path, initheader = { 'Content-Type' => 'application/json'})
            request.body = parameters
        end
        
        response = Net::HTTP.new(url.host).start {|http| http.request(request) }

        if response.kind_of? Net::HTTPSuccess
            return JSON.parse(response.body)["content"]
        else
            puts JSON.parse(response.body)
            return nil
        end
    end

    def _executeGetRequest(endpoint, parameters = [])
        return _executeHTTPRequest(endpoint, parameters, "GET")
    end

    def _executePostRequest(endpoint, parameters = [])
        return _executeHTTPRequest(endpoint, parameters, "POST")
    end

    def _executePutRequest(endpoint, parameters = [])
        return _executeHTTPRequest(endpoint, parameters, "PUT")
    end

    def _executeDeleteRequest(endpoint, parameters = [])
        return _executeHTTPRequest(endpoint, parameters, "DELETE")    
    end
    
    # getUser: Get user account details for a JotForm user
    # @return [json] Returns user account type, avatar URL, name, email, website URL and account limits.
    def getUser
        return _executeGetRequest("user")
    end

    # getUsage: Get number of form submissions received this month
    # @return [json] Returns number of submissions, number of SSL form submissions, payment form submissions and upload space used by user.
    def getUsage
        return _executeGetRequest("user/usage");
    end

    # getForms: Get a list of forms for this account
    # @return [json] Returns basic details such as title of the form, when it was created, number of new and total submissions.
    def getForms
        return _executeGetRequest("user/forms")
    end

    # getSubmissions: Get a list of submissions for this account
    # @return [json] Returns basic details such as title of the form, when it was created, number of new and total submissions.
    def getSubmissions
        return _executeGetRequest("user/submissions")
    end

    # getSubusers: Get a list of sub users for this account
    # @return [json] Returns list of forms and form folders with access privileges.
    def getSubusers
        return _executeGetRequest("user/subusers")
    end

    # getFolders: Get a list of form folders for this account
    # @return [json] Returns name of the folder and owner of the folder for shared folders.
    def getFolders
        return _executeGetRequest("user/folders")
    end

    # getReports: List of URLS for reports in this account
    # @return [json] Returns reports for all of the forms. ie. Excel, CSV, printable charts, embeddable HTML tables.
    def getReports
        return _executeGetRequest("user/reports")
    end

    # getSettings: Get user's settings for this account
    # @return [json] Returns user's time zone and language.
    def getSettings
        return _executeGetRequest("user/settings")
    end

    # updateSettings: Update user's settings
    # @param [hash:settings] New user setting values with setting keys
    # @return [json] Returns changes on user settings
    def updateSettings(settings)
        return _executePostRequest('user/settings', settings)
    end

    # getHistory: Get user activity log
    # @return [json] Returns activity log about things like forms created/modified/deleted, account logins and other operations.
    def getHistory
        return _executeGetRequest("user/history")
    end

    # getForm: Get basic information about a form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns form ID, status, update and creation dates, submission count etc.
    def getForm(formID)
        return _executeGetRequest("form/" + formID)
    end

    # getFormQuestions: Get a list of all questions of a form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns question properties of a form.
    def getFormQuestions(formID)
        return _executeGetRequest("form/" + formID + "/questions")
    end

    # getFormQuestion: Get details about a question
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [string:qid] You can get Question IDs when you call /form/{id}/questions.
    # @return [json] Returns question properties like required and validation.
    def getFormQuestion(formID, qid)
        return _executeGetRequest("form/" + formID + "/question/" + qid)
    end

    # getFormProperties: Get a list of all properties of a form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns form properties like width, expiration date, style etc.
    def getFormProperties(formID)
        return _executeGetRequest("form/" + formID + "/properties")
    end

    # getFormProperty: Get a specific property of the form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [string:propertyKey]
    # @return [json] Returns given property key value.
    def getFormProperty(formID, propertyKey)
        return _executeGetRequest("form/" + formID + "/properties/" + propertyKey)
    end

    # getFormSubmissions: Get list of a form submissions
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns submissions of a specific form.
    def getFormSubmissions(formID)
        return _executeGetRequest("form/" + formID + "/submissions")
    end

    # createFormSubmissions: Submit data to this form using the API
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [hash:submission] Submission data with question IDs
    # @return [json] Returns posted submission ID and URL.
    def createFormSubmissions(formID, submission)
        clearedSubmission = {}
        submission.each do |key, value|
            if key.include? '_'
                exploded = key.split('_')
                qid = exploded.first()
                type = exploded.last()
                clearedSubmission["submission[" + qid + "][" + type + "]"] = value
            else 
                clearedSubmission["submission[" + key + "]"] = value
            end
        end
        return _executePostRequest("form/"+ formID +"/submissions", clearedSubmission)
    end

    # getFormFiles: List of files uploaded on a form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns uploaded file information and URLs on a specific form.
    def getFormFiles(formID)
        return _executeGetRequest("form/" + formID + "/files")
    end

    # getFormWebhooks: Get list of webhooks for a form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns list of webhooks for a specific form.
    def getFormWebhooks(formID)
        return _executeGetRequest("form/" + formID + "/webhooks")
    end

    # createFormWebhook: Add a new webhook
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [string:webhookURL] Webhook URL is where form data will be posted when form is submitted.
    # @return [json] Returns list of webhooks for a specific form.
    def createFormWebhook(formID, webhookURL)
        return _executePostRequest("form/" + formID + "/webhooks", {"webhookURL" => webhookURL})
    end

    # TODO
    def deleteFormWebhook(formID, webhookID)
        return
    end

    # getSubmission: Get submission data
    # @param [string:sid] You can get submission IDs when you call /form/{id}/submissions.
    # @return [json] Returns information and answers of a specific submission.
    def getSubmission(sid)
        return _executeGetRequest("submission/" + sid)
    end

    # getReport: Get report details
    # @param [string:reportID] You can get a list of reports from /user/reports.
    # @return [json] Returns properties of a speceific report like fields and status.
    def getReport(reportID)
        return _executeGetRequest("report/" + reportID)
    end

    # getFolder: Get folder details
    # @param [string:folderID] You can get a list of folders from /user/folders.
    # @return [json] Returns a list of forms in a folder, and other details about the form such as folder color.
    def getFolder(folderID) 
        return _executeGetRequest("folder/" + folderID)
    end

    # createFolder: Create a folder
    # @param [hash:folderProperties] Properties of new folder.
    # @return [json] New folder.
    def createFolder(folderProperties)
        return _executePostRequest("folder", folderProperties)
    end

    # deleteFolder: Delete a specific folder and its subfolder
    # @param [string:folderID] You can get a list of folders from /user/folders.
    # @return [json] Returns status of request.
    def deleteFolder(folderID)
        return _executeDeleteRequest("folder/" + folderID)
    end

    # updateFolder: Update a specific folder
    # @param  [string:folderID] You can get a list of folders from /user/folders.
    # @param  [json:folderProperties] New properties of the specified folder.
    # @return [json] Returns status of request.
    def updateFolder(folderID, folderProperties)
        return _executePutRequest("folder/" + folderID, folderProperties)
    end
    
    # addFormsToFolder: Add forms to the specified folder
    # @param  [string:folderID] You can get the list of folders from /user/folders.
    # @param  [array:formIDs] You can get the list of forms from /user/forms.
    # @return [json] Returns status of request.
    def addFormsToFolder(folderID, formIDs)
        data = {
            "forms" => formIDs
        }

        return updateFolder(folderID, data.to_json)
    end

    # addFormToFolder: Add a form to the specified folder
    # @param  [string:folderID] You can get the list of folders from /user/folders.
    # @param  [string:formID] You can get the list of forms from /user/forms.
    # @return [json] Returns status of request.
    def addFormToFolder(folderID, formID)
        data = {
            "forms" => [formID]
        }

        return updateFolder(folderID, data.to_json)
    end

    # getFormReports: Get all the reports of a form, such as excel, csv, grid, html, etc.
    # @param  [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns a list of reports in a form, and other details about the reports such as title.
    def getFormReports(formID)
        return _executeGetRequest("form/" + formID + "/reports")
    end

    # createReport: Create new report of a form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [hash:report] Report details. List type, title etc.
    # @return [json] Returns report details and URL.
    def createReport(formID, report)
        return _executePostRequest("form/" + formID + "/reports", report)
    end

    # deleteSubmission: Delete a single submission
    # @param  [string:sid] You can get submission IDs when you call /user/submissions.
    # @return [json] Returns status of request.
    def deleteSubmission(sid)
        return _executeDeleteRequest("submission/" + sid)
    end

    # editSubmission: Edit a single submission
    # @param [string:sid] You can get submission IDs when you call /form/{id}/submissions.
    # @param [hash:submission] New submission data with question IDs.
    # @return [json] Returns status of request.
    def editSubmission(sid, submission)
        clearedSubmission = {};

        submission.each do |key, value|
            if key.include? '_' && key != 'created_at'
                exploded = key.split('_')
                qid = exploded.first()
                type = exploded.last()
                clearedSubmission["submission[" + qid + "][" + type + "]"] = value
            else 
                clearedSubmission["submission[" + key + "]"] = value
            end
        end

        return _executePostRequest("submission/" + sid, clearedSubmission)
    end

    # cloneForm: Clone a single form
    # @param  [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return [json] Returns status of request.
    def cloneForm(formID)
        return _executePostRequest("form/" + formID + "/clone", {})
    end

    # deleteFormQuestion: Delete a single form question
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [string:qid] Identifier for each question on a form. You can get a list of question IDs from /form/{id}/questions.
    # @return [json] Returns status of request.
    def deleteFormQuestion(formID, qid)
        return _executeDeleteRequest("form/" + formID + "/question/" + qid)
    end

    # createFormQuestion: Add new question to specified form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [hash:question] New question properties like type and text.
    # @return [json] Returns properties of new question.
    def createFormQuestion(formID, question)
        clearedQuestion = {}
        question.each do |key, value|
            clearedQuestion["question[" + key + "]"] = value
        end

        return _executePostRequest("form/" + formID + "/questions", clearedQuestion)
    end
    
    # createFormQuestions: Add new questions to specified form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [json] New question properties like type and text.
    # @return [json] Returns properties of new questions.
    def createFormQuestions(formID, questions)
        return _executePutRequest("form/" + formID + "/questions", questions)
    end

    # editFormQuestion: Add or edit a single question properties
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [string:qid] Identifier for each question on a form. You can get a list of question IDs from /form/{id}/questions.
    # @param [hash:questionProperties] New question properties like text and order.
    # @return [json] Returns edited property and type of question.
    def editFormQuestion(formID, qid, questionProperties)
        question = {}
        
        questionProperties.each do |key, value|
            question["question[" + key + "]"] = value
        end

        return _executePostRequest("form/" + formID + "/question/" + qid, question)
    end

    # setFormProperties: Add or edit properties of a specific form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [hash:formProperties] New properties like label, width etc.
    # @return [json] Returns edited properties.
    def setFormProperties(formID, formProperties)
        properties = {}

        formProperties.each do |key, value|
            properties["properties[" + key + "]"] = value
        end

        return _executePostRequest("form/" + formID + "/properties", properties)
    end

    # setMultipleFormProperties: Add or edit properties of a specific form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @param [json:formProperties] New properties like label width.
    # @return [json] Returns edited properties.
    def setMultipleFormProperties(formID, formProperties)
        return _executePutRequest("form/" + formID + "/properties", formProperties)
    end

    # createForm: Create a new form
    # @param [hash:form] Questions, properties and emails of new form.
    # @return [json] Returns new form.
    def createForm(form)
        clearedForm = {}

        form.each do |key, value|
            value.each do |k, v|
                if key == "properties"
                    clearedForm[key + "[" + k + "]"] = v
                else
                    v.each do |a, b|
                        clearedForm[key + "[" + k + "][" + a + "]"] = b
                    end
                end
            end
        end

        return _executePostRequest("user/forms", clearedForm)
    end

    # createForm: Create new forms
    # @param [json:form] Questions, properties and emails of forms.
    # @return [json] Returns new forms.
    def createForms(form)
        return _executePutRequest("user/forms", form)
    end

    # deleteForm: Delete a specific form
    # @param [string:formID] Form ID is the numbers you see on a form URL. You can get form IDs when you call /user/forms.
    # @return  [json] Returns roperties of deleted form.
    def deleteForm(formID)
        return _executeDeleteRequest("form/" + formID)
    end

    # registerUser: Register with username, password and email
    # @param [hash:userDetails] username, password and email to register a new user.
    # @return [json] Returns new user's details.
    def registerUser(userDetails)
        return _executePostRequest("user/register", userDetails)
    end

    # loginUser: Login user with given credentials
    # @param [hash:credentials] Username, password, application name and access type of user.
    # @return [json] Returns logged in user's settings and app key.
    def loginUser(credentials)
        return _executePostRequest("user/login", credentials)
    end

    # logoutUser: Logout user
    # @return [json] Status of the request.
    def logoutUser
        return _executeGetRequest("user/logout")
    end

    # getPlan: Get details of a plan
    # @param [string:planName] Name of the requested plan. FREE, GOLD etc.
    # @return [json] Returns details of a plan.
    def getPlan(planName)
        return _executeGetRequest("system/plan/" + planName)
    end

    # deleteReport: Delete a specific report
    # @param [string:reportID] You can get a list of reports from /user/reports.
    # @return [json] Returns status of request.
    def deleteReport(reportID)
        return _executeDeleteRequest("report/" + reportID)
    end
end
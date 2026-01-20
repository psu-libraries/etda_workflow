# Issue #955 Implementation Guide (Updated with Actual Data Structure)
## Create Committee API Endpoint in ETDA Workflow

### Overview
Based on the actual database structure, here's what we know:

**Data Model:**
- `committee_members` table stores faculty committee memberships
- Each committee member belongs to a `submission` (thesis/dissertation)
- Each committee member has a `committee_role` (Chair, Member, etc.)
- Committee members have `access_id` (faculty PSU access ID)
- Approval tracking: `approved_at`, `rejected_at`, `approval_started_at`

**Goal:** Create an API endpoint that accepts a faculty's `access_id` and returns all their committee memberships.

---

## Step-by-Step Implementation

### Step 1: Understand the Data Relationships

From the Rails console exploration, we know:

```
CommitteeMember
├── belongs_to :submission (the thesis/dissertation)
├── belongs_to :committee_role (Chair, Member, etc.)
├── belongs_to :faculty_member (the faculty's Author record)
└── belongs_to :approver

Submission
├── belongs_to :author (the student)
├── belongs_to :program
├── belongs_to :degree
└── has_many :committee_members
```

**Key fields:**
- `committee_members.access_id` - Faculty PSU access ID (this is what we'll search by)
- `committee_members.name` - Faculty name
- `committee_members.email` - Faculty email
- `committee_members.status` - Current status
- `submissions.title` - Thesis/dissertation title
- `submissions.defended_at` - Defense date
- `committee_roles.name` - Role name (e.g., "Committee Chair/Co-Chair", "Committee Member")

### Step 2: Create the API Controller

Generate the controller:

```bash
# In the web container
bundle exec rails generate controller Api::Committees
```

This creates:
- `app/controllers/api/committees_controller.rb`
- `spec/controllers/api/committees_controller_spec.rb`

### Step 3: Add the Route

Edit `config/routes.rb`:

```ruby
# Add this inside Rails.application.routes.draw do
  namespace :api do
    resources :committees, only: [] do
      collection do
        post :faculty_committees
      end
    end
  end
```

This creates the route: `POST /api/committees/faculty_committees`

### Step 4: Implement the Controller

Edit `app/controllers/api/committees_controller.rb`:

```ruby
module Api
  class CommitteesController < ApplicationController
    # Skip CSRF token verification for API requests
    skip_before_action :verify_authenticity_token
    
    # Authentication filter
    before_action :authenticate_api_key
    
    # POST /api/committees/faculty_committees
    # Expected params: { access_id: "xyz123" }
    # Returns: JSON with all committee memberships for the faculty member
    #
    # Example request:
    #   curl -X POST http://localhost:3000/api/committees/faculty_committees \
    #     -H "Content-Type: application/json" \
    #     -H "Authorization: your-api-key" \
    #     -d '{"access_id": "abc123"}'
    #
    def faculty_committees
      access_id = params[:access_id]
      
      # Validate required parameter
      if access_id.blank?
        render json: { error: 'access_id is required' }, status: :bad_request
        return
      end
      
      # Find all committee memberships for this faculty member
      # Note: We search by access_id which is the PSU ID
      committee_memberships = CommitteeMember
        .includes(:submission, :committee_role)
        .where(access_id: access_id)
      
      # Format the response
      response_data = {
        faculty_access_id: access_id,
        committees: format_committees(committee_memberships)
      }
      
      render json: response_data, status: :ok
    end
    
    private
    
    # Authenticate using API Key from environment variable
    # The API Key should be passed in the Authorization header
    def authenticate_api_key
      provided_key = request.headers['Authorization']
      expected_key = ENV['COMMITTEE_API_KEY']
      
      unless provided_key.present? && provided_key == expected_key
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
    
    # Format committee memberships for Activity Insight
    # Returns an array of committee membership objects
    def format_committees(committee_memberships)
      committee_memberships.map do |membership|
        submission = membership.submission
        
        # Build the committee data object
        {
          # Committee member info
          committee_member_id: membership.id,
          faculty_name: membership.name,
          faculty_email: membership.email,
          faculty_access_id: membership.access_id,
          
          # Committee role
          role: membership.committee_role&.name,
          role_code: membership.committee_role&.code,
          
          # Student information
          student_name: submission.author&.name || "Unknown",
          student_access_id: submission.author&.access_id,
          
          # Submission information
          submission_id: submission.id,
          title: submission.title,
          degree_name: submission.degree&.name,
          program_name: submission.program&.name,
          semester: submission.semester,
          year: submission.year,
          
          # Important dates
          defended_at: submission.defended_at,
          committee_provided_at: submission.committee_provided_at,
          final_submission_approved_at: submission.final_submission_approved_at,
          
          # Status information
          submission_status: submission.status,
          committee_member_status: membership.status,
          approved_at: membership.approved_at,
          rejected_at: membership.rejected_at,
          
          # Additional metadata
          is_required: membership.is_required,
          is_voting: membership.is_voting,
          federal_funding_used: membership.federal_funding_used
        }
      end
    end
  end
end
```

### Step 5: Add API Key to Environment

Edit your `.envrc` file:

```bash
# Add this line
export COMMITTEE_API_KEY="your-secure-api-key-here-change-this"
```

Then reload:
```bash
# Exit the container first (type 'exit')
# Then in your local terminal:
direnv allow

# Restart the web container to pick up new env var
docker-compose restart web
```

### Step 6: Test the Endpoint

#### Test in Rails Console

```bash
# Access the web container
docker-compose exec web bash

# Open Rails console
bundle exec rails console

# Find a faculty member with committee memberships
# First, let's see what access_ids exist
CommitteeMember.where.not(access_id: nil).pluck(:access_id).uniq.first(5)

# Pick one access_id and test the query
test_access_id = "abc123" # Replace with an actual access_id from above
memberships = CommitteeMember.includes(:submission, :committee_role).where(access_id: test_access_id)
puts "Found #{memberships.count} committee memberships"

# Look at the first one
m = memberships.first
puts "Faculty: #{m.name}"
puts "Role: #{m.committee_role&.name}"
puts "Submission: #{m.submission&.title}"
```

#### Test with curl

```bash
# Replace 'abc123' with an actual access_id from your database
# Replace 'your-api-key' with the key you set in .envrc

curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-secure-api-key-here-change-this" \
  -d '{"access_id": "abc123"}'
```

#### Test with Postman/Insomnia

1. Method: `POST`
2. URL: `http://localhost:3000/api/committees/faculty_committees`
3. Headers:
   - `Content-Type: application/json`
   - `Authorization: your-secure-api-key-here-change-this`
4. Body (JSON):
   ```json
   {
     "access_id": "abc123"
   }
   ```

### Step 7: Write Tests

Create `spec/requests/api/committees_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe 'Api::Committees', type: :request do
  let(:api_key) { 'test-api-key' }
  let(:headers) do
    {
      'Authorization' => api_key,
      'Content-Type' => 'application/json'
    }
  end
  
  before do
    # Set the API key for tests
    allow(ENV).to receive(:[]).with('COMMITTEE_API_KEY').and_return(api_key)
    allow(ENV).to receive(:[]).and_call_original
  end
  
  describe 'POST /api/committees/faculty_committees' do
    let(:faculty_access_id) { 'xyz123' }
    
    context 'with valid API key' do
      context 'when faculty has committee memberships' do
        let!(:author) { create(:author, access_id: 'student123') }
        let!(:degree) { create(:degree, name: 'Doctor of Philosophy') }
        let!(:program) { create(:program, name: 'Computer Science') }
        let!(:submission) do
          create(:submission,
                 author: author,
                 degree: degree,
                 program: program,
                 title: 'A Study of Important Things',
                 defended_at: Time.zone.parse('2024-12-01'))
        end
        let!(:committee_role) { create(:committee_role, name: 'Committee Chair/Co-Chair') }
        let!(:committee_member) do
          create(:committee_member,
                 access_id: faculty_access_id,
                 name: 'Dr. Jane Smith',
                 email: 'jsmith@psu.edu',
                 submission: submission,
                 committee_role: committee_role)
        end
        
        it 'returns committee memberships' do
          post '/api/committees/faculty_committees',
               params: { access_id: faculty_access_id }.to_json,
               headers: headers
          
          expect(response).to have_http_status(:ok)
          
          json = JSON.parse(response.body)
          expect(json['faculty_access_id']).to eq(faculty_access_id)
          expect(json['committees']).to be_an(Array)
          expect(json['committees'].length).to eq(1)
          
          committee = json['committees'].first
          expect(committee['faculty_name']).to eq('Dr. Jane Smith')
          expect(committee['faculty_email']).to eq('jsmith@psu.edu')
          expect(committee['role']).to eq('Committee Chair/Co-Chair')
          expect(committee['title']).to eq('A Study of Important Things')
          expect(committee['degree_name']).to eq('Doctor of Philosophy')
          expect(committee['student_name']).to eq(author.name)
        end
      end
      
      context 'when faculty has no committee memberships' do
        it 'returns empty array' do
          post '/api/committees/faculty_committees',
               params: { access_id: 'nonexistent' }.to_json,
               headers: headers
          
          expect(response).to have_http_status(:ok)
          
          json = JSON.parse(response.body)
          expect(json['committees']).to eq([])
        end
      end
      
      context 'when access_id is missing' do
        it 'returns bad request error' do
          post '/api/committees/faculty_committees',
               params: {}.to_json,
               headers: headers
          
          expect(response).to have_http_status(:bad_request)
          
          json = JSON.parse(response.body)
          expect(json['error']).to eq('access_id is required')
        end
      end
      
      context 'when access_id is blank' do
        it 'returns bad request error' do
          post '/api/committees/faculty_committees',
               params: { access_id: '' }.to_json,
               headers: headers
          
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
    
    context 'with invalid API key' do
      let(:bad_headers) do
        {
          'Authorization' => 'wrong-key',
          'Content-Type' => 'application/json'
        }
      end
      
      it 'returns unauthorized error' do
        post '/api/committees/faculty_committees',
             params: { access_id: faculty_access_id }.to_json,
             headers: bad_headers
        
        expect(response).to have_http_status(:unauthorized)
        
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Unauthorized')
      end
    end
    
    context 'without API key' do
      let(:no_auth_headers) do
        { 'Content-Type' => 'application/json' }
      end
      
      it 'returns unauthorized error' do
        post '/api/committees/faculty_committees',
             params: { access_id: faculty_access_id }.to_json,
             headers: no_auth_headers
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
```

Run the tests:
```bash
# In the web container
RAILS_ENV=test bundle exec rspec spec/requests/api/committees_spec.rb
```

### Step 8: Check Routes

Verify your route was created correctly:

```bash
# In the web container
bundle exec rails routes | grep faculty_committees
```

You should see:
```
faculty_committees_api_committees POST /api/committees/faculty_committees(.:format) api/committees#faculty_committees
```

### Step 9: Create API Documentation

Create `docs/api/committees.md`:

```markdown
# Committee API

## Overview
This API endpoint provides committee membership data for faculty members from the ETDA Workflow system. It is designed to be consumed by the FAMS Tool, which will then push the data to Activity Insight.

## Authentication
Uses simple API Key authentication. Include the API key in the `Authorization` header.

The API key is stored in the `COMMITTEE_API_KEY` environment variable on the server.

## Endpoint

### Get Faculty Committee Memberships

Retrieves all committee memberships for a given faculty member.

**URL:** `POST /api/committees/faculty_committees`

**Method:** `POST`

**Authentication Required:** Yes

#### Request Headers
```
Content-Type: application/json
Authorization: <API_KEY>
```

#### Request Body
```json
{
  "access_id": "faculty_psu_access_id"
}
```

**Parameters:**
- `access_id` (string, required): The PSU access ID of the faculty member

#### Success Response

**Code:** `200 OK`

**Content:**
```json
{
  "faculty_access_id": "xyz123",
  "committees": [
    {
      "committee_member_id": 1234,
      "faculty_name": "Dr. Jane Smith",
      "faculty_email": "jsmith@psu.edu",
      "faculty_access_id": "xyz123",
      "role": "Committee Chair/Co-Chair",
      "role_code": "CC",
      "student_name": "John Doe",
      "student_access_id": "jd456",
      "submission_id": 5678,
      "title": "A Study of Important Topics in Computer Science",
      "degree_name": "Doctor of Philosophy",
      "program_name": "Computer Science",
      "semester": "Fall",
      "year": "2024",
      "defended_at": "2024-12-01T14:00:00.000Z",
      "committee_provided_at": "2024-01-15T10:00:00.000Z",
      "final_submission_approved_at": "2024-12-15T16:30:00.000Z",
      "submission_status": "approved",
      "committee_member_status": "approved",
      "approved_at": "2024-12-01T15:00:00.000Z",
      "rejected_at": null,
      "is_required": true,
      "is_voting": true,
      "federal_funding_used": false
    }
  ]
}
```

#### Error Responses

**Code:** `400 Bad Request`
```json
{
  "error": "access_id is required"
}
```

**Code:** `401 Unauthorized`
```json
{
  "error": "Unauthorized"
}
```

#### Field Descriptions

**Committee Member Fields:**
- `committee_member_id`: Internal database ID for the committee membership record
- `faculty_name`: Full name of the faculty member
- `faculty_email`: Email address of the faculty member
- `faculty_access_id`: PSU access ID of the faculty member
- `role`: Human-readable committee role (e.g., "Committee Chair/Co-Chair", "Committee Member")
- `role_code`: Short code for the role

**Student Fields:**
- `student_name`: Full name of the student
- `student_access_id`: PSU access ID of the student

**Submission Fields:**
- `submission_id`: Internal database ID for the submission
- `title`: Title of the thesis/dissertation
- `degree_name`: Name of the degree (e.g., "Doctor of Philosophy", "Master of Science")
- `program_name`: Academic program name
- `semester`: Semester of submission (Fall, Spring, Summer)
- `year`: Year of submission

**Date Fields:**
- `defended_at`: Date and time of thesis defense
- `committee_provided_at`: Date when committee was provided
- `final_submission_approved_at`: Date when final submission was approved

**Status Fields:**
- `submission_status`: Current status of the submission
- `committee_member_status`: Current status of the committee member's approval
- `approved_at`: Date when committee member approved
- `rejected_at`: Date when committee member rejected (null if not rejected)

**Boolean Fields:**
- `is_required`: Whether this committee member is required
- `is_voting`: Whether this is a voting member
- `federal_funding_used`: Whether federal funding was involved

## Usage Example

### Using curl

```bash
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-api-key-here" \
  -d '{
    "access_id": "xyz123"
  }'
```

### Using Ruby (for FAMS Tool integration)

```ruby
require 'net/http'
require 'json'

uri = URI('http://etda-workflow.psu.edu/api/committees/faculty_committees')
request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request['Authorization'] = ENV['ETDA_API_KEY']
request.body = { access_id: 'xyz123' }.to_json

response = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(request)
end

if response.is_a?(Net::HTTPSuccess)
  data = JSON.parse(response.body)
  committees = data['committees']
  # Process committees...
else
  puts "Error: #{response.code} - #{response.body}"
end
```

## Notes

- Returns an empty array if the faculty member has no committee memberships
- All date/time fields are in ISO 8601 format with UTC timezone
- The endpoint includes all historical committee memberships, not just current ones
- Committee roles may vary by degree type (PhD, Masters, etc.)
```

### Step 10: Manual Testing Checklist

Before creating a PR, test these scenarios:

```bash
# 1. Test with valid faculty member
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-api-key" \
  -d '{"access_id": "REAL_ACCESS_ID_HERE"}'

# 2. Test with nonexistent faculty member
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-api-key" \
  -d '{"access_id": "nonexistent"}'

# 3. Test with missing access_id
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-api-key" \
  -d '{}'

# 4. Test with wrong API key
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: wrong-key" \
  -d '{"access_id": "xyz123"}'

# 5. Test with no API key
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -d '{"access_id": "xyz123"}'
```

### Step 11: Questions for Your Mentor

Before finalizing, confirm these details:

1. **Data scope**: Should we return ALL committee memberships (historical + current) or filter by date/status?
2. **Degree types**: Should we filter by specific degree types (PhD, Masters, Honors)?
3. **Status filtering**: Should we only return approved submissions, or all statuses?
4. **Performance**: For faculty with many committee memberships, should we implement pagination?
5. **Additional fields**: Are there any other fields from the database that Activity Insight needs?
6. **API Key management**: How should the API key be generated and shared with the FAMS Tool team?

### Step 12: Creating the Pull Request

Once everything is tested:

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/issue-955-committee-api
   ```

2. **Commit your changes:**
   ```bash
   git add app/controllers/api/committees_controller.rb
   git add config/routes.rb
   git add spec/requests/api/committees_spec.rb
   git add docs/api/committees.md
   git commit -m "Add API endpoint for faculty committee memberships (Issue #955)
   
   - Created Api::CommitteesController with faculty_committees action
   - Implemented API key authentication
   - Added comprehensive tests
   - Documented API endpoint
   
   Closes #955"
   ```

3. **Push to GitHub:**
   ```bash
   git push origin feature/issue-955-committee-api
   ```

4. **Create Pull Request** on GitHub with:
   - Link to issue #955
   - Description of what was implemented
   - Testing instructions
   - Screenshots of curl test results

### Common Issues & Solutions

**Issue: "LoadError: Unable to autoload constant CommitteeMember"**
- Solution: The model file doesn't exist. Check `app/models/committee_member.rb`

**Issue: "NameError: uninitialized constant Api"**
- Solution: Make sure the controller is in `app/controllers/api/` directory

**Issue: "No route matches [POST] '/api/committees/faculty_committees'"**
- Solution: Restart the Rails server: `docker-compose restart web`

**Issue: API returns 401 even with correct key**
- Solution: Restart web container after adding COMMITTEE_API_KEY to .envrc

**Issue: Empty response for known faculty member**
- Solution: Check that the faculty member has a valid `access_id` in the database

### Next Steps

After your PR is merged:

1. **QA Testing**: Test in QA environment with real data
2. **FAMS Tool Integration**: Coordinate with the FAMS Tool team to integrate this endpoint
3. **Activity Insight Import**: Work on the FAMS Tool side to push this data to Activity Insight
4. **Documentation**: Update any relevant documentation with the new API endpoint

---

## Summary

You've created a RESTful API endpoint that:
- ✅ Accepts a faculty member's PSU access ID
- ✅ Returns all their committee memberships with detailed information
- ✅ Uses simple API key authentication
- ✅ Is well-documented and tested
- ✅ Follows Rails conventions and best practices
- ✅ Is ready to be consumed by the FAMS Tool

The data will flow: **ETDA Workflow API → FAMS Tool → Activity Insight**

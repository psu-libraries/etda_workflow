# Fundamentals for Building the Committee API Controller

## What Issue #955 Requires

From the screenshot, you need to build an API endpoint that:
1. Receives a POST request with a faculty's access ID
2. Retrieves all committee data for that faculty
3. Returns the data as JSON
4. Uses simple API Key authentication
5. Has basic documentation

---

## Core Concepts You Need to Understand

### 1. What is an API?

**Simple Definition**: An API (Application Programming Interface) is a way for one program to talk to another program.

**In this case:**
- **FAMS Tool** (one program) needs data from **ETDA Workflow** (another program)
- Instead of using a web browser, FAMS Tool sends a request programmatically
- ETDA responds with data in JSON format

**Real-world analogy:**
- Web browser → shows HTML pages for humans
- API → returns JSON data for other programs

---

### 2. HTTP Methods and Routes

**HTTP Methods** are verbs that describe what action you want to take:

```
GET    = Retrieve/Read data    (like viewing a page)
POST   = Create/Send data      (like submitting a form)
PUT    = Update data           (like editing a profile)
DELETE = Remove data           (like deleting a comment)
```

**For this API:**
- Method: `POST` (even though we're just reading data, POST is specified in the issue)
- Path: `/api/committees/faculty_committees`
- Full URL: `http://localhost:3000/api/committees/faculty_committees`

**Routes in Rails:**
The route tells Rails which controller action to call:

```ruby
# config/routes.rb
namespace :api do
  resources :committees, only: [] do
    collection do
      post :faculty_committees  # ← Creates POST /api/committees/faculty_committees
    end
  end
end
```

This says: "When someone POSTs to /api/committees/faculty_committees, call the `faculty_committees` method in Api::CommitteesController"

---

### 3. Controllers and Actions

**Controller** = A Ruby class that handles web requests
**Action** = A method in the controller that does the work

```ruby
module Api
  class CommitteesController < ApplicationController
    
    # This is an ACTION
    def faculty_committees
      # 1. Get the input
      # 2. Query the database
      # 3. Format the response
      # 4. Return JSON
    end
    
  end
end
```

**The flow:**
```
Request comes in
    ↓
Rails checks routes
    ↓
Routes say: "Call Api::CommitteesController#faculty_committees"
    ↓
Controller action runs
    ↓
Response sent back
```

---

### 4. Request and Response

**Request** = What the client sends to the server

```ruby
# What FAMS Tool sends:
POST /api/committees/faculty_committees
Headers:
  Content-Type: application/json
  Authorization: secret-api-key
Body:
  {
    "access_id": "jms123"
  }
```

**Response** = What the server sends back

```ruby
# What ETDA returns:
Status: 200 OK
Headers:
  Content-Type: application/json
Body:
  {
    "faculty_access_id": "jms123",
    "committees": [...]
  }
```

**In the controller:**

```ruby
def faculty_committees
  # ACCESS REQUEST DATA
  access_id = params[:access_id]           # ← Get from request body
  api_key = request.headers['Authorization'] # ← Get from headers
  
  # QUERY DATABASE
  data = CommitteeMember.where(access_id: access_id)
  
  # SEND RESPONSE
  render json: { committees: data }, status: :ok
end
```

---

### 5. Working with Params

**Params** = Parameters sent in the request

```ruby
# If request body is:
{
  "access_id": "jms123",
  "other_field": "value"
}

# In controller:
params[:access_id]   # → "jms123"
params[:other_field] # → "value"
```

**Example:**

```ruby
def faculty_committees
  # Get the access_id from params
  access_id = params[:access_id]
  
  # Validate it exists
  if access_id.blank?
    render json: { error: 'access_id is required' }, status: :bad_request
    return
  end
  
  # Use it to query database
  members = CommitteeMember.where(access_id: access_id)
end
```

---

### 6. Querying the Database with ActiveRecord

**ActiveRecord** = Rails' way to interact with the database

**Basic queries:**

```ruby
# Find all committee members with a specific access_id
CommitteeMember.where(access_id: "jms123")

# Find one by access_id
CommitteeMember.find_by(access_id: "jms123")

# Include related data (avoid N+1 queries)
CommitteeMember
  .includes(:submission, :committee_role)
  .where(access_id: "jms123")
```

**In your controller:**

```ruby
def faculty_committees
  access_id = params[:access_id]
  
  # Query the database
  committee_memberships = CommitteeMember
    .includes(submission: [:author, :degree, :program])
    .where(access_id: access_id)
  
  # committee_memberships is now an array of CommitteeMember objects
end
```

---

### 7. Rendering JSON Responses

**JSON** = JavaScript Object Notation (a data format)

```ruby
# Render a hash as JSON
render json: { message: "Hello" }
# Returns: {"message":"Hello"}

# Render with status code
render json: { error: "Not found" }, status: :not_found
# Returns: {"error":"Not found"} with HTTP 404

# Render an array
render json: { committees: [1, 2, 3] }
# Returns: {"committees":[1,2,3]}
```

**Status codes:**

```ruby
status: :ok              # 200 - Success
status: :bad_request     # 400 - Client error (missing params)
status: :unauthorized    # 401 - Authentication failed
status: :not_found       # 404 - Resource not found
status: :internal_server_error  # 500 - Server error
```

**In your controller:**

```ruby
def faculty_committees
  # Success case
  render json: { faculty_access_id: "jms123", committees: [...] }, status: :ok
  
  # Error case
  render json: { error: "access_id is required" }, status: :bad_request
end
```

---

### 8. Authentication with API Keys

**API Key** = A secret token that identifies and authorizes the client

**How it works:**

```
Client request:
  POST /api/committees/faculty_committees
  Authorization: my-secret-key-12345
  
Server checks:
  Is "my-secret-key-12345" == ENV['COMMITTEE_API_KEY']?
  
  ✓ Yes → Process request
  ✗ No  → Return 401 Unauthorized
```

**In the controller:**

```ruby
class CommitteesController < ApplicationController
  # This runs BEFORE every action
  before_action :authenticate_api_key
  
  private
  
  def authenticate_api_key
    # Get the key from request header
    provided_key = request.headers['Authorization']
    
    # Get the expected key from environment
    expected_key = ENV['COMMITTEE_API_KEY']
    
    # Check if they match
    unless provided_key == expected_key
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
```

---

### 9. Using Rails Associations

**Associations** = Relationships between models

```ruby
# CommitteeMember model has these associations:
belongs_to :submission        # ← Each member belongs to one submission
belongs_to :committee_role    # ← Each member has one role

# Submission model has these associations:
belongs_to :author            # ← Each submission has one author (student)
belongs_to :degree
belongs_to :program
```

**Using associations in code:**

```ruby
# Start with a committee member
member = CommitteeMember.first

# Navigate to related records
member.submission              # → The thesis/dissertation
member.submission.author       # → The student
member.submission.degree       # → The degree
member.committee_role          # → The faculty's role
```

**The data flow:**

```ruby
member = CommitteeMember.find_by(access_id: "jms123")

# Get submission
submission = member.submission  # Uses submission_id

# Get student from submission
student = submission.author     # Uses author_id

# Build response
{
  faculty_name: member.name,
  student_name: student.name,
  title: submission.title
}
```

---

### 10. Building the Response

**Mapping data** = Transforming database records into the format you want

```ruby
def format_committees(committee_memberships)
  # Use .map to transform each membership
  committee_memberships.map do |membership|
    {
      # Pull data from the membership
      faculty_name: membership.name,
      faculty_email: membership.email,
      
      # Pull data from related submission
      title: membership.submission.title,
      student_name: membership.submission.author.name,
      
      # Pull data from related role
      role: membership.committee_role.name
    }
  end
end
```

**Example:**

```ruby
# Input: Array of CommitteeMember objects
members = [
  <CommitteeMember id: 1, name: "Dr. Smith", submission_id: 100>,
  <CommitteeMember id: 2, name: "Dr. Smith", submission_id: 101>
]

# Process: Map to hashes
result = members.map do |m|
  {
    faculty_name: m.name,
    title: m.submission.title
  }
end

# Output: Array of hashes
[
  { faculty_name: "Dr. Smith", title: "AI Research" },
  { faculty_name: "Dr. Smith", title: "ML Study" }
]
```

---

## Putting It All Together

Here's the complete flow for your API:

```ruby
module Api
  class CommitteesController < ApplicationController
    # Step 1: Skip CSRF protection (this is an API, not a web form)
    skip_before_action :verify_authenticity_token
    
    # Step 2: Authenticate every request
    before_action :authenticate_api_key
    
    # Step 3: The main action
    def faculty_committees
      # Get input from request
      access_id = params[:access_id]
      
      # Validate input
      if access_id.blank?
        render json: { error: 'access_id is required' }, status: :bad_request
        return
      end
      
      # Query database
      memberships = CommitteeMember
        .includes(submission: [:author, :degree, :program])
        .where(access_id: access_id)
      
      # Format response
      committees = memberships.map do |m|
        {
          faculty_name: m.name,
          student_name: m.submission.author&.name,
          title: m.submission.title,
          role: m.committee_role&.name
        }
      end
      
      # Return JSON
      render json: {
        faculty_access_id: access_id,
        committees: committees
      }, status: :ok
    end
    
    private
    
    # Authentication helper
    def authenticate_api_key
      provided = request.headers['Authorization']
      expected = ENV['COMMITTEE_API_KEY']
      
      unless provided == expected
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
```

---

## Key Learning Resources

### Rails Guides to Read:

1. **Action Controller Overview**
   https://guides.rubyonrails.org/action_controller_overview.html
   - Focus on: Sections 2-4 (Parameters, Session, Rendering)

2. **Active Record Query Interface**
   https://guides.rubyonrails.org/active_record_querying.html
   - Focus on: where, find_by, includes

3. **Active Record Associations**
   https://guides.rubyonrails.org/association_basics.html
   - Focus on: belongs_to, has_many

### Practice Exercises:

1. **Test in Rails Console:**
   ```ruby
   # Find a committee member
   member = CommitteeMember.first
   
   # Navigate associations
   member.submission
   member.submission.author
   member.committee_role
   
   # Query with conditions
   CommitteeMember.where(access_id: "xyz123")
   
   # Map to hashes
   CommitteeMember.first(3).map { |m| { name: m.name } }
   ```

2. **Build a Simple Controller:**
   - Start with just returning `{ message: "Hello" }`
   - Add params: Return the access_id back
   - Add database query: Return count of committee members
   - Add full response: Return formatted data

---

## Testing Your API

### Using curl:

```bash
# Test the endpoint
curl -X POST http://localhost:3000/api/committees/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-api-key" \
  -d '{"access_id": "jms123"}'
```

### Using Rails Console:

```ruby
# Test the query logic
access_id = "jms123"
memberships = CommitteeMember
  .includes(submission: [:author, :degree])
  .where(access_id: access_id)

memberships.each do |m|
  puts "Faculty: #{m.name}"
  puts "Student: #{m.submission.author.name}"
  puts "Title: #{m.submission.title}"
  puts "---"
end
```

---

## Common Mistakes to Avoid

1. **Forgetting to check for nil:**
   ```ruby
   # Bad
   student_name: submission.author.name  # Crashes if author is nil
   
   # Good
   student_name: submission.author&.name  # Returns nil safely
   ```

2. **N+1 queries (slow):**
   ```ruby
   # Bad - makes many queries
   CommitteeMember.where(access_id: id).each do |m|
     puts m.submission.title  # One query per member!
   end
   
   # Good - preloads data
   CommitteeMember.includes(:submission).where(access_id: id).each do |m|
     puts m.submission.title  # No extra queries!
   end
   ```

3. **Not validating input:**
   ```ruby
   # Bad
   access_id = params[:access_id]
   members = CommitteeMember.where(access_id: access_id)  # What if nil?
   
   # Good
   access_id = params[:access_id]
   if access_id.blank?
     render json: { error: 'Required' }, status: :bad_request
     return
   end
   ```

4. **Forgetting authentication:**
   ```ruby
   # Add this to protect your API
   before_action :authenticate_api_key
   ```

---

## Next Steps

1. **Read the Rails Controller guide** (focus on basics)
2. **Practice in Rails console** with CommitteeMember queries
3. **Generate the controller**: `bundle exec rails generate controller Api::Committees`
4. **Start simple**: Make it return `{ message: "Hello" }` first
5. **Add complexity**: Add the query, then formatting, then authentication
6. **Test as you go**: Use curl to test after each step

---

## Questions to Ask Yourself

As you build:
- ✓ What HTTP method am I using? (POST)
- ✓ What route am I creating? (/api/committees/faculty_committees)
- ✓ What parameters am I accepting? (access_id)
- ✓ How do I query the database? (CommitteeMember.where...)
- ✓ What associations do I need? (submission, author, degree, etc.)
- ✓ How do I format the response? (.map with a hash)
- ✓ What status codes do I return? (200, 400, 401)
- ✓ How do I authenticate? (Check Authorization header)

You've got this! Start with the basics and build up step by step.

# Understanding the Data Mapping - Step by Step

## The Big Picture

**Goal**: Given a faculty member's `access_id`, return all their committee memberships with full details.

**Example**: Dr. Jane Smith (access_id: "jms123") wants to see all the students she has advised.

---

## The Database Structure

Let's visualize the tables and how they connect:

```
┌─────────────────────────┐
│   FACULTY INPUT         │
│  access_id: "jms123"    │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────────────────────────────────────────┐
│                    COMMITTEE_MEMBERS                        │
│  id: 1                                                      │
│  submission_id: 100    ← CONNECTIVE TISSUE!                │
│  committee_role_id: 4                                       │
│  access_id: "jms123"   ← This matches the input            │
│  name: "Dr. Jane Smith"                                     │
│  email: "jms123@psu.edu"                                    │
│  faculty_member_id: 50                                      │
│  approved_at: "2024-12-01"                                  │
└─────────────────────────────────────────────────────────────┘
            │                           │
            │                           │
    submission_id: 100        committee_role_id: 4
            │                           │
            ↓                           ↓
┌─────────────────────────┐   ┌──────────────────────┐
│      SUBMISSIONS        │   │   COMMITTEE_ROLES    │
│  id: 100                │   │  id: 4               │
│  author_id: 200         │   │  name: "Chair"       │
│  program_id: 10         │   │  code: "CC"          │
│  degree_id: 5           │   └──────────────────────┘
│  title: "AI Research"   │
│  defended_at: "2024..."  │
│  status: "approved"     │
└─────────────────────────┘
      │         │        │
      │         │        │
  author_id  program_id degree_id
      │         │        │
      ↓         ↓        ↓
┌────────┐ ┌─────────┐ ┌────────┐
│ AUTHORS│ │PROGRAMS │ │DEGREES │
│ id: 200│ │ id: 10  │ │ id: 5  │
│ name:  │ │ name:   │ │ name:  │
│ "John" │ │ "CS"    │ │ "PhD"  │
└────────┘ └─────────┘ └────────┘
```

---

## Step-by-Step Data Flow in the Controller

### STEP 1: The Request Comes In

```ruby
# User sends this:
POST /api/committees/faculty_committees
{
  "access_id": "jms123"
}
```

### STEP 2: Extract the Parameter

```ruby
def faculty_committees
  access_id = params[:access_id]  # ← Gets "jms123"
  
  # Validate it exists
  if access_id.blank?
    render json: { error: 'access_id is required' }, status: :bad_request
    return
  end
```

### STEP 3: Query the Database

```ruby
  # Find ALL committee memberships for this faculty member
  committee_memberships = CommitteeMember
    .includes(:submission, :committee_role)  # ← Preload related data
    .where(access_id: access_id)             # ← Where access_id = "jms123"
```

**What this query does:**

1. Searches `committee_members` table for `access_id = "jms123"`
2. Finds all matching rows (could be 0, 1, or many)
3. Also loads the related `submission` and `committee_role` for each row

**Example result (in memory):**

```ruby
# Array of CommitteeMember objects
[
  #<CommitteeMember:0x001
    id: 1,
    submission_id: 100,
    committee_role_id: 4,
    access_id: "jms123",
    name: "Dr. Jane Smith",
    email: "jms123@psu.edu",
    approved_at: "2024-12-01",
    submission: #<Submission:0x002 id: 100, author_id: 200, title: "AI Research"...>,
    committee_role: #<CommitteeRole:0x003 id: 4, name: "Committee Chair/Co-Chair">
  >,
  #<CommitteeMember:0x004
    id: 2,
    submission_id: 101,
    ...another committee membership...
  >
]
```

### STEP 4: Format Each Committee Membership

```ruby
  # Format the response
  response_data = {
    faculty_access_id: access_id,
    committees: format_committees(committee_memberships)  # ← Format each one
  }
```

This calls the `format_committees` method:

```ruby
def format_committees(committee_memberships)
  committee_memberships.map do |membership|
    # For each committee membership...
```

### STEP 5: Extract Data from Each Membership

Let's walk through ONE committee membership:

```ruby
    # Get the submission (thesis/dissertation) - already loaded!
    submission = membership.submission
    
    # Example:
    # submission.id = 100
    # submission.title = "Artificial Intelligence in Healthcare"
    # submission.author_id = 200
    # submission.degree_id = 5
    # submission.program_id = 10
    # submission.defended_at = "2024-12-01"
```

Now we build the output hash:

```ruby
    {
      # ============================================
      # COMMITTEE MEMBER INFO (from committee_members table)
      # ============================================
      committee_member_id: membership.id,           # 1
      faculty_name: membership.name,                # "Dr. Jane Smith"
      faculty_email: membership.email,              # "jms123@psu.edu"
      faculty_access_id: membership.access_id,      # "jms123"
      
      # ============================================
      # COMMITTEE ROLE (from committee_roles table via committee_role_id)
      # ============================================
      role: membership.committee_role&.name,        # "Committee Chair/Co-Chair"
      role_code: membership.committee_role&.code,   # "CC"
      
      # ============================================
      # STUDENT INFO (from authors table via submission.author_id)
      # ============================================
      student_name: submission.author&.name,         # "John Doe"
      student_access_id: submission.author&.access_id, # "jd456"
      
      # ============================================
      # SUBMISSION INFO (from submissions table)
      # ============================================
      submission_id: submission.id,                  # 100
      title: submission.title,                       # "AI in Healthcare"
      degree_name: submission.degree&.name,          # "Doctor of Philosophy"
      program_name: submission.program&.name,        # "Computer Science"
      semester: submission.semester,                 # "Fall"
      year: submission.year,                         # 2024
      
      # ============================================
      # DATES (from submissions table)
      # ============================================
      defended_at: submission.defended_at,           # "2024-12-01"
      committee_provided_at: submission.committee_provided_at,
      final_submission_approved_at: submission.final_submission_approved_at,
      
      # ============================================
      # STATUS (from both tables)
      # ============================================
      submission_status: submission.status,          # "approved"
      committee_member_status: membership.status,    # "approved"
      approved_at: membership.approved_at,           # "2024-12-01"
      rejected_at: membership.rejected_at,           # nil
      
      # ============================================
      # BOOLEAN FLAGS (from committee_members table)
      # ============================================
      is_required: membership.is_required,           # true
      is_voting: membership.is_voting,               # true
      federal_funding_used: membership.federal_funding_used # false
    }
```

---

## Visual Example with Real Data

**Input:**
```json
{
  "access_id": "jms123"
}
```

**Database Query Finds:**

```
committee_members table:
┌────┬───────────────┬───────────────────┬─────────┬──────────────────┐
│ id │ submission_id │ committee_role_id │ access_id│ name            │
├────┼───────────────┼───────────────────┼─────────┼──────────────────┤
│ 1  │ 100           │ 4                 │ jms123  │ Dr. Jane Smith  │
│ 2  │ 101           │ 5                 │ jms123  │ Dr. Jane Smith  │
└────┴───────────────┴───────────────────┴─────────┴──────────────────┘
        ↓                      ↓
        
submissions table (via submission_id):
┌─────┬───────────┬──────────────────────────┬────────────┐
│ id  │ author_id │ title                    │ degree_id  │
├─────┼───────────┼──────────────────────────┼────────────┤
│ 100 │ 200       │ AI in Healthcare         │ 5          │
│ 101 │ 201       │ Machine Learning Study   │ 5          │
└─────┴───────────┴──────────────────────────┴────────────┘
        ↓                                        ↓
        
authors table:                    degrees table:
┌─────┬──────────┐              ┌────┬─────────────────────┐
│ id  │ name     │              │ id │ name                │
├─────┼──────────┤              ├────┼─────────────────────┤
│ 200 │ John Doe │              │ 5  │ Doctor of Philosophy│
│ 201 │ Jane Roe │              └────┴─────────────────────┘
└─────┴──────────┘
```

**Output:**

```json
{
  "faculty_access_id": "jms123",
  "committees": [
    {
      "committee_member_id": 1,
      "faculty_name": "Dr. Jane Smith",
      "faculty_email": "jms123@psu.edu",
      "faculty_access_id": "jms123",
      "role": "Committee Chair/Co-Chair",
      "student_name": "John Doe",
      "title": "AI in Healthcare",
      "degree_name": "Doctor of Philosophy",
      "defended_at": "2024-12-01"
      // ... more fields ...
    },
    {
      "committee_member_id": 2,
      "faculty_name": "Dr. Jane Smith",
      "faculty_email": "jms123@psu.edu",
      "faculty_access_id": "jms123",
      "role": "Committee Member",
      "student_name": "Jane Roe",
      "title": "Machine Learning Study",
      "degree_name": "Doctor of Philosophy",
      "defended_at": "2024-11-15"
      // ... more fields ...
    }
  ]
}
```

---

## The Key Rails Associations

In the controller, we use Rails associations to navigate the relationships:

```ruby
# Starting point: membership (CommitteeMember object)
membership = CommitteeMember.find_by(access_id: "jms123")

# Navigate to submission
submission = membership.submission
# This uses: belongs_to :submission
# SQL: SELECT * FROM submissions WHERE id = membership.submission_id

# Navigate to author (student)
author = submission.author
# This uses: belongs_to :author (in Submission model)
# SQL: SELECT * FROM authors WHERE id = submission.author_id

# Navigate to degree
degree = submission.degree
# This uses: belongs_to :degree (in Submission model)
# SQL: SELECT * FROM degrees WHERE id = submission.degree_id

# Navigate to committee role
role = membership.committee_role
# This uses: belongs_to :committee_role (in CommitteeMember model)
# SQL: SELECT * FROM committee_roles WHERE id = membership.committee_role_id
```

---

## Why `.includes(:submission, :committee_role)`?

```ruby
CommitteeMember
  .includes(:submission, :committee_role)
  .where(access_id: access_id)
```

**Without `.includes`:**
- Rails would make 1 query to get committee_members
- Then 1 query for EACH submission (N+1 problem)
- Then 1 query for EACH committee_role
- If there are 10 memberships, that's 21 queries total!

**With `.includes`:**
- Rails makes 3 queries total:
  1. Get all committee_members where access_id matches
  2. Get all related submissions in one query
  3. Get all related committee_roles in one query
- Much faster and more efficient!

---

## The Safe Navigation Operator `&.`

You'll see this throughout the code:

```ruby
submission.author&.name
```

**What it does:**
- If `submission.author` is `nil`, it returns `nil` instead of crashing
- Equivalent to: `submission.author ? submission.author.name : nil`

**Why we need it:**
- Sometimes data might be incomplete
- An author might not exist in the database
- Better to return `nil` than crash the API

---

## Putting It All Together

Here's the complete flow in pseudocode:

```
1. User sends: { "access_id": "jms123" }

2. Controller receives it:
   access_id = "jms123"

3. Query database:
   Find all rows in committee_members where access_id = "jms123"
   Also preload their submissions and committee_roles

4. For each committee membership found:
   a. Get the submission (thesis)
   b. From submission, get the author (student)
   c. From submission, get the degree
   d. From submission, get the program
   e. Get the committee role
   f. Build a hash with all this info

5. Return JSON:
   {
     "faculty_access_id": "jms123",
     "committees": [
       { all the info from step 4 },
       { all the info from step 4 },
       ...
     ]
   }
```

---

## Testing the Logic in Rails Console

You can test this logic step by step in Rails console:

```ruby
# Find a faculty member
access_id = "jms123"  # Use a real one from your database

# Get their committee memberships
memberships = CommitteeMember.where(access_id: access_id)
puts "Found #{memberships.count} memberships"

# Look at the first one
m = memberships.first

# Navigate the relationships
puts "Committee Member: #{m.name}"
puts "Role: #{m.committee_role&.name}"
puts "Submission ID: #{m.submission_id}"
puts "Submission Title: #{m.submission&.title}"
puts "Student: #{m.submission&.author&.name}"
puts "Student Access ID: #{m.submission&.author&.access_id}"
puts "Degree: #{m.submission&.degree&.name}"
puts "Program: #{m.submission&.program&.name}"
puts "Defense Date: #{m.submission&.defended_at}"
```

---

## Summary

**The mapping is:**

```
access_id (input)
  ↓
committee_members (find by access_id)
  ↓
submission_id (the connective tissue!)
  ↓
submission (has all the thesis info)
  ├─→ author_id → Author (student info)
  ├─→ degree_id → Degree (PhD, MS, etc.)
  ├─→ program_id → Program (Computer Science, etc.)
  └─→ dates, title, status, etc.
  
committee_role_id
  ↓
committee_role (Chair, Member, etc.)
```

**The controller code simply:**
1. Finds all committee memberships by access_id
2. For each membership, follows the foreign keys to get related data
3. Packages it all into a nice JSON response

That's it! The `submission_id` is the key that unlocks all the related information.

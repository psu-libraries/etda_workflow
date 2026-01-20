# Issue #955 - Quick Start Guide

## What I'm Building
API endpoint to return faculty committee memberships for Activity Insight integration.

## Read These First (in order)
1. `api_fundamentals_guide.md` - Understand API basics
2. `data_mapping_explanation.md` - Understand the data flow
3. `issue_955_updated_guide.md` - Full implementation guide

## Quick Context

### The Goal
Input: Faculty access_id (e.g., "jms123")
Output: All their committee memberships with student, thesis, and role info

### The Database Flow
```
faculty access_id
    ↓
committee_members.access_id (search here)
    ↓
committee_members.submission_id (connective tissue!)
    ↓
submissions table (has student, degree, program)
    ↓
Get: student info, thesis title, dates, etc.
```

### Key Files to Work On
- [ ] Work on: `app/controllers/api/committee_records_controller.rb`
- [ ] Update: `config/routes.rb`
- [ ] Create: `spec/requests/api/committee_records_spec.rb`

### Environment Setup
- [ ] Add to .envrc: `export COMMITTEE_API_KEY="your-key-here"`
- [ ] Reload: `direnv allow`
- [ ] Restart: `docker-compose restart web`

### Current Branch
`api-controller` (checked out from coworker's work)

### Next Steps
1. Review the guides in this directory
2. Use Claude Code to implement the controller
3. Test in Rails console first
4. Test with curl
5. Write tests
6. Create PR

## Testing Commands

### Rails Console
```bash
docker-compose exec web bash
bundle exec rails console

# Test query
CommitteeMember.where.not(access_id: nil).pluck(:access_id).uniq.first(5)
memberships = CommitteeMember.includes(:submission, :committee_role).where(access_id: "REAL_ID")
```

### curl Test
```bash
curl -X POST http://localhost:3000/api/committee_records/faculty_committees \
  -H "Content-Type: application/json" \
  -H "Authorization: your-api-key" \
  -d '{"access_id": "jms123"}'
```

## Important Notes
- `submission_id` is the connective tissue that links everything
- Use `.includes()` to avoid N+1 queries
- Map ETDA data to Activity Insight format (see issue_955_updated_guide.md)
- Safe navigation operator `&.` for nil safety

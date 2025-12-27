# Phase 2 Roadmap: GitVerse World & Multi-NPC Features

**Status:** Planning Phase
**Prerequisites:** Phase 1 Complete ✅ (Awaiting Testing)
**Timeline:** TBD based on Phase 1 test results
**ATOM:** ATOM-PLAN-20251228-001

---

## Executive Summary

Phase 1 delivered a single working AI-powered NPC. Phase 2 expands this into **GitVerse** - a full Minecraft world where NPCs represent different aspects of a Git repository, creating an explorable, educational code visualization platform.

**Vision:** Transform GitLab/GitHub repositories into interactive Minecraft worlds where players learn code structure through spatial exploration and NPC conversations.

---

## Phase 1 → Phase 2 Transition

### What Phase 1 Proved
- ✅ Claude API integration works
- ✅ NPC conversation system functional
- ✅ Memory management effective
- ✅ Multi-player isolation works
- ✅ Async architecture scales

### What Phase 2 Adds
- 🎯 Multiple NPC types (different roles/expertise)
- 🎯 World generation from Git repository data
- 🎯 Building structures represent code modules
- 🎯 Visual repository navigation
- 🎯 Quest system for code exploration
- 🎯 Analytics and learning tracking

---

## Phase 2 Architecture

### High-Level Design

```
GitVerse World
├── World Generator
│   ├── Parse Git repository
│   ├── Map directories → buildings
│   ├── Map files → rooms
│   └── Generate NPC placements
│
├── NPC Types
│   ├── Guide NPC (repository overview)
│   ├── Module Expert NPCs (per directory)
│   ├── Code Reviewer NPC (PR discussions)
│   ├── Documentation NPC (README/docs)
│   └── History NPC (git log, commits)
│
├── Interaction Systems
│   ├── Building entry → code exploration
│   ├── Signs with code snippets
│   ├── Quest boards (find functions, fix bugs)
│   └── Leaderboards (exploration progress)
│
└── Integration Layer
    ├── GitHub/GitLab API client
    ├── Repository cache/sync
    ├── Code syntax highlighting in chat
    └── Live repository updates
```

---

## Core Features Breakdown

### Feature 1: Multi-NPC System

**Current (Phase 1):** Single NPC type, manual personality configuration

**Phase 2 Enhancement:**
- NPC role system with predefined personalities
- Auto-generate NPCs from repository structure
- Specialized NPCs:
  - **Guide NPC:** "Welcome to the repository! Let me show you around..."
  - **Module Expert:** "I handle authentication. Ask me about login/security!"
  - **Code Reviewer:** "I see you're looking at PR #42. The issue is on line 127..."
  - **Historian:** "This function was added in commit abc123 by..."

**Implementation:**
```java
public enum NPCRole {
    GUIDE("Repository overview and navigation"),
    MODULE_EXPERT("Specific module/directory expertise"),
    CODE_REVIEWER("Pull request and code review discussions"),
    DOCUMENTATION("README, docs, and learning resources"),
    HISTORIAN("Git history, commits, and evolution"),
    DEBUGGER("Bug hunting and troubleshooting");

    private final String description;
}
```

**Effort:** Medium (2-3 days)
**Priority:** High

---

### Feature 2: Repository World Generator

**Concept:** Automatically generate Minecraft world from Git repository structure

**Mapping Rules:**
- **Repository root** → Spawn point with central plaza
- **Directories** → Buildings (size based on file count)
- **Files** → Rooms within buildings (connected hallways)
- **Important files** (README, main.js, etc.) → Larger/decorated rooms
- **Git branches** → Different districts/neighborhoods
- **Commit history** → Timeline path/road

**Example Visualization:**
```
Real Repository:
src/
├── auth/
│   ├── login.js
│   └── session.js
├── ui/
│   └── components/
└── utils/

Minecraft World:
Central Plaza
├── Auth Building (2 floors)
│   ├── Login Room (NPC: Login Expert)
│   └── Session Room (NPC: Session Expert)
├── UI Building (1 floor + basement)
│   └── Components Wing (NPC: UI Designer)
└── Utils Building (single tower)
```

**Implementation Components:**
1. **Git Parser:** Read repository structure
2. **World Generator API:** Use WorldEdit/Schematics
3. **Building Templates:** Pre-designed structures by size
4. **NPC Placer:** Position NPCs in relevant rooms
5. **Sign Generator:** Display code snippets on signs

**Effort:** Large (1-2 weeks)
**Priority:** High (core feature)

---

### Feature 3: Code Snippet Visualization

**Goal:** Display actual code in-game for learning

**Approaches:**

**Option A: Signs & Books**
- Place signs in rooms with key code lines
- Give players books with full file contents
- Color-coded signs for syntax highlighting

**Option B: Custom Chat UI**
- `/claudenpc view <file>` shows code in chat
- Pagination for large files
- Syntax highlighting via color codes

**Option C: Maps (Advanced)**
- Use Minecraft maps to render code as images
- Allows actual "viewing" of code files
- Requires image generation pipeline

**Recommendation:** Start with Option B (easiest), explore Option C later

**Effort:** Small-Medium (2-4 days)
**Priority:** Medium

---

### Feature 4: Quest System

**Purpose:** Guide players through codebase exploration

**Quest Types:**

1. **Treasure Hunt Quests**
   - "Find the authentication function"
   - "Locate where we handle database connections"
   - Reward: Experience, understanding

2. **Bug Hunt Quests**
   - "There's a null pointer bug in User.java - can you find it?"
   - NPC provides hints if asked
   - Reward: Mark as "Code Reviewer" rank

3. **Learning Path Quests**
   - "Complete the Authentication module tour"
   - Visit all NPCs in auth building
   - Answer trivia about the code
   - Reward: Unlock advanced NPCs

4. **Code Review Quests**
   - "Review PR #42 and discuss with Code Reviewer NPC"
   - Examine proposed changes
   - Discuss trade-offs with NPC
   - Reward: Contributor badge

**Implementation:**
```java
public class Quest {
    String id;
    String title;
    String description;
    QuestType type;
    List<QuestObjective> objectives;
    Map<UUID, QuestProgress> playerProgress;
}
```

**Effort:** Medium (3-5 days)
**Priority:** Medium (enhances engagement)

---

### Feature 5: GitHub/GitLab Integration

**Capability:** Sync repository data in real-time

**Features:**
- Repository URL configuration
- OAuth authentication
- Periodic sync (commits, PRs, issues)
- Update NPCs with latest information
- Notify players of new commits/PRs

**API Integration:**
```java
public interface RepositoryProvider {
    Repository fetchRepository(String url);
    List<Commit> getCommits(String branch, int limit);
    List<PullRequest> getPullRequests(String state);
    String getFileContent(String path, String branch);
}

// Implementations
public class GitHubProvider implements RepositoryProvider { }
public class GitLabProvider implements RepositoryProvider { }
```

**Effort:** Medium (4-6 days)
**Priority:** High (enables dynamic updates)

---

### Feature 6: Analytics & Learning Tracking

**Purpose:** Measure learning effectiveness

**Metrics to Track:**
- Rooms visited (code coverage)
- NPCs talked to
- Time spent per module
- Questions asked
- Quests completed
- Code snippets viewed

**Visualization:**
- In-game scoreboards
- Web dashboard (optional)
- Discord webhooks for achievements

**Storage:**
- SQLite database for player data
- JSON exports for analysis

**Effort:** Small-Medium (2-3 days)
**Priority:** Low (nice-to-have)

---

## Technical Considerations

### Performance

**Challenges:**
- Large repositories → Large worlds (lag)
- Many NPCs → Many AI calls (cost)
- Real-time sync → API rate limits

**Solutions:**
- Lazy-load buildings (generate on approach)
- Cache NPC responses (reduce API calls)
- Throttle repository sync (hourly/daily)
- Use Haiku model for basic NPCs (cheaper)
- Sonnet for complex code discussions

### Scalability

**Phase 2 Scope:**
- Single repository per world
- Up to 100 NPCs
- 50 concurrent players

**Future Phases:**
- Multi-repository support
- Thousands of NPCs
- Dedicated server clusters

### Cost Management

**API Cost Optimization:**
- Response caching (identical questions)
- Tiered models (Haiku for simple, Sonnet for complex)
- Rate limiting per player
- Monthly budget caps

**Estimated Costs (50 players, moderate usage):**
- Phase 1: $50-100/month
- Phase 2: $200-500/month
- Production: $500-2000/month (depends on usage)

---

## Development Phases

### Phase 2.1: Multi-NPC Foundation (Week 1-2)

**Goals:**
- NPC role system
- Multiple NPC types
- Role-based personalities
- Basic world with 5-10 NPCs

**Deliverables:**
- Enhanced NPC system
- Test world with varied NPCs
- Documentation for NPC creation

**Success Criteria:**
- 5+ different NPC roles working
- Distinct personalities per role
- Player can identify NPC expertise

---

### Phase 2.2: Repository Parser (Week 3-4)

**Goals:**
- Git repository parsing
- Structure analysis
- Basic world generation

**Deliverables:**
- Git parser library
- Repository analyzer
- Simple building generator

**Success Criteria:**
- Parse real repository
- Generate basic world layout
- Buildings match directory structure

---

### Phase 2.3: World Building (Week 5-6)

**Goals:**
- Advanced world generation
- Building templates
- NPC auto-placement
- Code snippet displays

**Deliverables:**
- Complete world generator
- Building template library
- Sign/book generation

**Success Criteria:**
- Full repository → Minecraft world
- NPCs in correct locations
- Code visible in-game

---

### Phase 2.4: GitHub Integration (Week 7-8)

**Goals:**
- GitHub API client
- Repository sync
- Live updates

**Deliverables:**
- GitHub integration
- Sync commands
- Update notifications

**Success Criteria:**
- Fetch repository from GitHub
- Sync commits/PRs
- NPCs know latest changes

---

### Phase 2.5: Quest System (Week 9-10)

**Goals:**
- Quest framework
- Basic quest types
- Progress tracking

**Deliverables:**
- Quest system
- 10+ sample quests
- Leaderboards

**Success Criteria:**
- Players can accept/complete quests
- Progress tracked
- Rewards functional

---

## Configuration Structure

### Phase 2 config.yml

```yaml
gitverse:
  # Repository Configuration
  repository:
    provider: "github"  # github, gitlab, local
    url: "https://github.com/user/repo"
    branch: "main"
    auth-token: ""  # GitHub personal access token

  # World Generation
  world-generation:
    enabled: true
    world-name: "GitVerse_MyRepo"
    spawn-location: [0, 64, 0]
    building-spacing: 50  # blocks between buildings
    max-buildings: 100

  # NPC Configuration
  npcs:
    auto-generate: true
    max-npcs: 100
    roles:
      guide:
        enabled: true
        personality: "Friendly and welcoming..."
      module-expert:
        enabled: true
        personality: "Knowledgeable about specific modules..."
      code-reviewer:
        enabled: true
        personality: "Analytical and detail-oriented..."

  # Quest System
  quests:
    enabled: true
    daily-quests: 3
    reward-multiplier: 1.0

  # Sync Settings
  sync:
    enabled: true
    interval: 3600  # seconds (1 hour)
    notify-players: true

  # Performance
  performance:
    lazy-load-buildings: true
    npc-render-distance: 50
    cache-responses: true
    cache-duration: 3600
```

---

## Risk Assessment

### High Risk

**Challenge:** Repository complexity
- **Risk:** Large repos create massive worlds (lag, overwhelm)
- **Mitigation:** Size limits, directory filtering, lazy loading

**Challenge:** API costs
- **Risk:** 100 NPCs × 50 players = expensive
- **Mitigation:** Aggressive caching, rate limits, budget caps

### Medium Risk

**Challenge:** Learning curve
- **Risk:** Players don't understand the metaphor
- **Mitigation:** Tutorial NPCs, clear documentation, quest guides

**Challenge:** Content quality
- **Risk:** Auto-generated NPCs give poor responses
- **Mitigation:** Curated personalities, human review, feedback loop

### Low Risk

**Challenge:** Technical complexity
- **Risk:** World generation is hard
- **Mitigation:** Use WorldEdit API, start simple, iterate

---

## Success Metrics

### Phase 2 Goals

**Technical:**
- [ ] Generate world from real repository
- [ ] 10+ NPC types functioning
- [ ] GitHub integration working
- [ ] Quest system operational
- [ ] <100ms average response time

**User Experience:**
- [ ] Players understand repository structure
- [ ] 80%+ positive feedback
- [ ] Average session >30 minutes
- [ ] Quest completion rate >50%

**Business:**
- [ ] API costs under budget
- [ ] Server stable for 24+ hours
- [ ] Documentation complete
- [ ] Demo-ready for GitLab City pitch

---

## Open Questions

1. **World Persistence:** Save world to disk or regenerate each time?
2. **Multi-Repository:** One world per repo or combined?
3. **Player Permissions:** Who can sync? Change NPCs? Run commands?
4. **Customization:** Allow users to modify generated world?
5. **Testing:** How to test with various repository sizes?
6. **Localization:** Support multiple languages?
7. **Mobile:** Bedrock edition support?

---

## Next Immediate Actions

### Before Starting Phase 2:

1. **Complete Phase 1 Testing**
   - Deploy to test server
   - Run full test suite
   - Gather feedback
   - Fix any critical bugs

2. **User Research**
   - Interview potential users
   - Understand use cases
   - Validate assumptions
   - Prioritize features

3. **Technical Proof-of-Concept**
   - Test WorldEdit API
   - Prototype building generation
   - Test GitHub API rate limits
   - Estimate costs at scale

4. **Get Approval**
   - Review roadmap with stakeholders
   - Confirm budget
   - Agree on timeline
   - Define success criteria

---

## Alternative Approaches

### Minimal Phase 2 (2 weeks)

Focus on multi-NPC only:
- 5 NPC types
- Manual world building
- No GitHub integration
- Basic quest system

**Pros:** Fast, low risk, validates NPC variety
**Cons:** Limited "wow" factor, manual work

### Maximum Phase 2 (3 months)

Full GitVerse vision:
- Complete world generation
- 20+ NPC types
- GitHub + GitLab integration
- Advanced quest system
- Analytics dashboard
- Web admin panel

**Pros:** Complete vision, impressive demo
**Cons:** Long timeline, high risk, expensive

### Recommended: Incremental Phase 2 (6-8 weeks)

Implement in order of value:
1. Multi-NPC system (foundation)
2. Repository parser (enables automation)
3. Basic world generation (visual impact)
4. GitHub integration (dynamic content)
5. Quest system (engagement)

**Pros:** Balanced, iterative, testable
**Cons:** Requires discipline to avoid scope creep

---

## Resources Needed

### Development
- 1 senior developer (full-time, 6-8 weeks)
- OR 2-3 part-time contributors
- Code review from Minecraft plugin experts

### Infrastructure
- Test Minecraft server (4GB+ RAM)
- GitHub API access (free tier OK for testing)
- CI/CD pipeline (GitHub Actions)
- Documentation hosting (GitHub Pages)

### Budget
- Development: $0-15k (depending on hiring)
- API costs (testing): $100-200/month
- Server hosting: $20-50/month
- Tools/licenses: $100

---

## Conclusion

Phase 2 transforms ClaudeNPC from a proof-of-concept into a true **code exploration platform**. The modular approach allows us to deliver value incrementally while managing risk.

**Recommended Path:**
1. ✅ Complete Phase 1 testing (1 week)
2. ✅ Validate Phase 2 approach (1 week research)
3. ✅ Start Phase 2.1 (multi-NPC foundation)
4. ✅ Iterate based on feedback

**Decision Point:** After Phase 1 testing, evaluate whether to:
- Proceed with full Phase 2 roadmap
- Pivot to simplified version
- Pause for user feedback
- Explore different use case

---

**Status:** Planning Complete - Awaiting Phase 1 Test Results

**ATOM:** ATOM-PLAN-20251228-001
**Author:** KENL System / Claude Sonnet 4.5
**Date:** 2025-12-28

**Next Review:** After Phase 1 testing complete

#!/usr/bin/env python3
"""
ATOM Trail Analytics - Advanced analysis tool
Provides visualization, pattern detection, and recovery insights
"""

import re
import sys
from pathlib import Path
from datetime import datetime, timedelta
from collections import Counter, defaultdict
from typing import List, Dict, Tuple, Optional

__version__ = "1.0.0"


class ATOMTag:
    """Represents a single ATOM tag entry"""

    def __init__(self, timestamp: datetime, tag: str, intent: str, context: str = ""):
        self.timestamp = timestamp
        self.tag = tag
        self.intent = intent
        self.context = context

        # Parse tag components
        parts = tag.split("-")
        if len(parts) >= 4:
            self.operation_type = parts[1]
            self.date = parts[2]
            self.counter = parts[3]
        else:
            self.operation_type = "UNKNOWN"
            self.date = ""
            self.counter = "000"

    def __repr__(self):
        return f"ATOMTag({self.tag}, {self.intent[:30]}...)"


class ATOMTrail:
    """Manages ATOM trail analysis"""

    def __init__(self, trail_file: Optional[Path] = None):
        if trail_file is None:
            trail_file = Path.home() / ".config" / "atom-sage" / "trails" / "atom_trail.log"

        self.trail_file = trail_file
        self.tags: List[ATOMTag] = []

        if self.trail_file.exists():
            self._load_trail()

    def _load_trail(self):
        """Load and parse ATOM trail file"""
        with open(self.trail_file, "r") as f:
            lines = f.readlines()

        current_tag = None
        for line in lines:
            line = line.strip()

            # Match ATOM tag line
            match = re.match(
                r"\[([^\]]+)\] (ATOM-[A-Z]+-\d{8}-\d{3}) \| (.+)", line
            )
            if match:
                timestamp_str, tag, intent = match.groups()
                timestamp = datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S")
                current_tag = ATOMTag(timestamp, tag, intent)
                self.tags.append(current_tag)

            # Match context line
            elif line.startswith("Context:") and current_tag:
                current_tag.context = line.replace("Context:", "").strip()

    def summary(self) -> Dict:
        """Generate summary statistics"""
        if not self.tags:
            return {"error": "No ATOM tags found"}

        total = len(self.tags)
        today = sum(1 for tag in self.tags if tag.timestamp.date() == datetime.now().date())

        type_counts = Counter(tag.operation_type for tag in self.tags)

        first_tag = self.tags[0]
        last_tag = self.tags[-1]

        return {
            "total_operations": total,
            "today_operations": today,
            "operations_by_type": dict(type_counts),
            "first_operation": {
                "timestamp": first_tag.timestamp.isoformat(),
                "intent": first_tag.intent,
            },
            "last_operation": {
                "timestamp": last_tag.timestamp.isoformat(),
                "intent": last_tag.intent,
            },
            "date_range_days": (last_tag.timestamp - first_tag.timestamp).days,
        }

    def recent(self, n: int = 10) -> List[ATOMTag]:
        """Get N most recent operations"""
        return self.tags[-n:]

    def filter_by_type(self, operation_type: str) -> List[ATOMTag]:
        """Filter tags by operation type"""
        return [tag for tag in self.tags if tag.operation_type == operation_type]

    def filter_by_date(self, date: datetime.date) -> List[ATOMTag]:
        """Filter tags by date"""
        return [tag for tag in self.tags if tag.timestamp.date() == date]

    def pending_tasks(self) -> List[ATOMTag]:
        """Find operations marked as TODO or pending"""
        keywords = ["TODO", "pending", "in progress", "incomplete"]
        return [
            tag
            for tag in self.tags
            if any(kw.lower() in tag.intent.lower() for kw in keywords)
            or tag.operation_type == "TASK"
        ]

    def recovery_analysis(self) -> Dict:
        """Analyze trail for recovery context"""
        if not self.tags:
            return {"error": "No trail to analyze"}

        recent = self.recent(20)
        pending = self.pending_tasks()
        last_status = [tag for tag in self.tags if tag.operation_type == "STATUS"]

        # Detect workflow patterns
        workflows = defaultdict(list)
        for tag in recent:
            workflows[tag.operation_type].append(tag)

        return {
            "recent_operations": [
                {
                    "timestamp": tag.timestamp.isoformat(),
                    "tag": tag.tag,
                    "intent": tag.intent,
                }
                for tag in recent
            ],
            "pending_tasks": [
                {"tag": tag.tag, "intent": tag.intent} for tag in pending
            ],
            "last_status": {
                "tag": last_status[-1].tag,
                "intent": last_status[-1].intent,
            }
            if last_status
            else None,
            "active_workflows": {
                op_type: len(tags) for op_type, tags in workflows.items()
            },
            "recovery_recommendation": self._generate_recovery_recommendation(
                recent, pending, workflows
            ),
        }

    def _generate_recovery_recommendation(
        self, recent: List[ATOMTag], pending: List[ATOMTag], workflows: Dict
    ) -> str:
        """Generate human-readable recovery recommendation"""
        if not recent:
            return "No recent activity to analyze"

        rec = ["Recovery Analysis:"]

        # Analyze recent activity
        rec.append(f"\n  Last {len(recent)} operations show:")
        for op_type, tags in sorted(workflows.items(), key=lambda x: -len(x[1])):
            rec.append(f"    - {len(tags)} {op_type} operation(s)")

        # Pending work
        if pending:
            rec.append(f"\n  {len(pending)} pending task(s):")
            for task in pending[:3]:  # Show first 3
                rec.append(f"    - {task.intent}")

        # Last known state
        last_tag = recent[-1]
        rec.append(f"\n  Last operation: {last_tag.intent}")
        rec.append(f"    at {last_tag.timestamp.strftime('%Y-%m-%d %H:%M')}")

        # Recommendation
        rec.append("\n  Recommended recovery action:")
        if pending:
            rec.append(f"    Continue with: {pending[0].intent}")
        elif workflows:
            most_active = max(workflows.items(), key=lambda x: len(x[1]))
            rec.append(f"    Resume {most_active[0]} workflow")
        else:
            rec.append("    Review recent operations and decide next step")

        return "\n".join(rec)

    def timeline_visualization(self, hours: int = 24) -> str:
        """Generate ASCII timeline of operations"""
        cutoff = datetime.now() - timedelta(hours=hours)
        recent = [tag for tag in self.tags if tag.timestamp >= cutoff]

        if not recent:
            return f"No operations in last {hours} hours"

        lines = [f"Timeline (last {hours} hours):", "=" * 70]

        for tag in recent:
            time_str = tag.timestamp.strftime("%H:%M")
            type_label = f"[{tag.operation_type:6s}]"
            intent_preview = tag.intent[:45]
            lines.append(f"{time_str} {type_label} {intent_preview}")

        return "\n".join(lines)

    def export_json(self, output_file: Path):
        """Export trail to JSON format"""
        import json

        data = {
            "trail_file": str(self.trail_file),
            "exported_at": datetime.now().isoformat(),
            "total_operations": len(self.tags),
            "operations": [
                {
                    "timestamp": tag.timestamp.isoformat(),
                    "tag": tag.tag,
                    "operation_type": tag.operation_type,
                    "intent": tag.intent,
                    "context": tag.context,
                }
                for tag in self.tags
            ],
        }

        with open(output_file, "w") as f:
            json.dump(data, f, indent=2)


def print_summary(trail: ATOMTrail):
    """Print formatted summary"""
    summary = trail.summary()

    if "error" in summary:
        print(f"Error: {summary['error']}")
        return

    print("\n" + "=" * 70)
    print("  ATOM Trail Summary")
    print("=" * 70)
    print(f"\nTotal operations: {summary['total_operations']}")
    print(f"Today's operations: {summary['today_operations']}")
    print(f"Date range: {summary['date_range_days']} days")
    print("\nOperations by type:")
    for op_type, count in sorted(
        summary["operations_by_type"].items(), key=lambda x: -x[1]
    ):
        print(f"  {op_type:12s}: {count:4d}")

    print(f"\nFirst operation:")
    print(f"  {summary['first_operation']['timestamp']}")
    print(f"  {summary['first_operation']['intent']}")

    print(f"\nLast operation:")
    print(f"  {summary['last_operation']['timestamp']}")
    print(f"  {summary['last_operation']['intent']}")
    print()


def print_recovery(trail: ATOMTrail):
    """Print recovery analysis"""
    analysis = trail.recovery_analysis()

    if "error" in analysis:
        print(f"Error: {analysis['error']}")
        return

    print("\n" + "=" * 70)
    print("  Recovery Analysis")
    print("=" * 70)

    print(f"\nRecent context ({len(analysis['recent_operations'])} operations):")
    print("-" * 70)
    for op in analysis["recent_operations"][-10:]:  # Show last 10
        timestamp = datetime.fromisoformat(op["timestamp"]).strftime("%H:%M")
        print(f"{timestamp} | {op['tag']} | {op['intent'][:40]}")

    if analysis["pending_tasks"]:
        print(f"\nPending tasks ({len(analysis['pending_tasks'])}):")
        print("-" * 70)
        for task in analysis["pending_tasks"]:
            print(f"  {task['tag']}: {task['intent']}")

    if analysis["last_status"]:
        print("\nLast status:")
        print("-" * 70)
        print(f"  {analysis['last_status']['tag']}: {analysis['last_status']['intent']}")

    print("\nActive workflows:")
    print("-" * 70)
    for workflow, count in sorted(
        analysis["active_workflows"].items(), key=lambda x: -x[1]
    ):
        print(f"  {workflow:12s}: {count} operation(s)")

    print(f"\n{analysis['recovery_recommendation']}")
    print()


def main():
    """CLI entry point"""
    import argparse

    parser = argparse.ArgumentParser(
        description="ATOM Trail Analytics - Advanced analysis tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    parser.add_argument("--trail-file", type=Path, help="Path to ATOM trail file")

    subparsers = parser.add_subparsers(dest="command", help="Command to execute")

    # Summary command
    subparsers.add_parser("summary", help="Show summary statistics")

    # Recent command
    recent_parser = subparsers.add_parser("recent", help="Show recent operations")
    recent_parser.add_argument("-n", type=int, default=10, help="Number of operations")

    # Type filter
    type_parser = subparsers.add_parser("type", help="Filter by operation type")
    type_parser.add_argument("operation_type", help="Operation type to filter")

    # Timeline
    timeline_parser = subparsers.add_parser("timeline", help="Show timeline")
    timeline_parser.add_argument(
        "--hours", type=int, default=24, help="Hours to show"
    )

    # Pending tasks
    subparsers.add_parser("pending", help="Show pending tasks")

    # Recovery analysis
    subparsers.add_parser("recovery", help="Recovery analysis")

    # Export
    export_parser = subparsers.add_parser("export", help="Export to JSON")
    export_parser.add_argument("output_file", type=Path, help="Output JSON file")

    args = parser.parse_args()

    # Load trail
    trail = ATOMTrail(args.trail_file)

    if not trail.tags:
        print("No ATOM trail found.")
        print("Start creating operations with: atom STATUS \"Your intent\"")
        return 1

    # Execute command
    if args.command == "summary" or args.command is None:
        print_summary(trail)

    elif args.command == "recent":
        recent = trail.recent(args.n)
        print(f"\nLast {len(recent)} operations:")
        print("-" * 70)
        for tag in recent:
            time_str = tag.timestamp.strftime("%Y-%m-%d %H:%M")
            print(f"{time_str} | {tag.tag} | {tag.intent}")

    elif args.command == "type":
        filtered = trail.filter_by_type(args.operation_type)
        print(f"\nOperations of type: {args.operation_type}")
        print("-" * 70)
        for tag in filtered:
            time_str = tag.timestamp.strftime("%Y-%m-%d %H:%M")
            print(f"{time_str} | {tag.tag} | {tag.intent}")

    elif args.command == "timeline":
        print(trail.timeline_visualization(args.hours))

    elif args.command == "pending":
        pending = trail.pending_tasks()
        print(f"\nPending tasks ({len(pending)}):")
        print("-" * 70)
        for tag in pending:
            print(f"{tag.tag}: {tag.intent}")

    elif args.command == "recovery":
        print_recovery(trail)

    elif args.command == "export":
        trail.export_json(args.output_file)
        print(f"Trail exported to: {args.output_file}")

    return 0


if __name__ == "__main__":
    sys.exit(main())

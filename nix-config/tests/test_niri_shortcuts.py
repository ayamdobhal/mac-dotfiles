import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('shortcuts', Path(__file__).resolve().parents[1] / 'modules/home/linux/niri-shortcuts.py')
shortcuts = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shortcuts)


class ShortcutTargets(unittest.TestCase):
    def test_cycle_wraps_only_on_focused_output(self):
        workspaces = [
            dict(id=1, idx=1, output='internal', is_focused=False),
            dict(id=2, idx=2, output='internal', is_focused=True),
            dict(id=3, idx=1, output='external', is_focused=False),
        ]
        self.assertEqual(shortcuts.workspace_target(workspaces, 'cycle'), 1)
        self.assertEqual(shortcuts.workspace_target(workspaces, 'new'), 2)

    def test_no_focused_workspace(self):
        self.assertIsNone(shortcuts.workspace_target([], 'cycle'))

    def test_swap_prefers_left_then_right_and_ignores_other_workspaces(self):
        def win(col, focus=False, workspace=1):
            return dict(is_focused=focus, is_floating=False, workspace_id=workspace,
                        layout=dict(pos_in_scrolling_layout=[col, 1]))
        self.assertEqual(shortcuts.swap_direction([win(2, True), win(1), win(3)]), 'left')
        self.assertEqual(shortcuts.swap_direction([win(1, True), win(2)]), 'right')
        self.assertIsNone(shortcuts.swap_direction([win(2, True), win(1, workspace=2)]))

    def test_floating_or_unavailable_layout_does_not_swap(self):
        for floating, pos in [(True, [1, 1]), (False, None)]:
            self.assertIsNone(shortcuts.swap_direction([dict(is_focused=True, is_floating=floating,
                workspace_id=1, layout=dict(pos_in_scrolling_layout=pos))]))


if __name__ == '__main__':
    unittest.main()

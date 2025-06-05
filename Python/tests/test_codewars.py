import unittest
import importlib.util
from pathlib import Path

CODEWARS_DIR = Path(__file__).resolve().parents[1] / "trainsel" / "Codewars"

# Load Chalange 1 module
chalange1_path = CODEWARS_DIR / "Chalange 1.py"
spec1 = importlib.util.spec_from_file_location("chalange1", chalange1_path)
chalange1 = importlib.util.module_from_spec(spec1)
spec1.loader.exec_module(chalange1)

# Load Chalange 2 module
chalange2_path = CODEWARS_DIR / "Chalange 2.py"
spec2 = importlib.util.spec_from_file_location("chalange2", chalange2_path)
chalange2 = importlib.util.module_from_spec(spec2)
spec2.loader.exec_module(chalange2)


class TestCodewars(unittest.TestCase):
    def test_solution_basic(self):
        self.assertEqual(chalange1.solution(10), 23)

    def test_solution_negative(self):
        self.assertEqual(chalange1.solution(-5), 0)

    def test_create_phone_number_basic(self):
        self.assertEqual(
            chalange2.create_phone_number(list(range(10))),
            "(012) 345-6789",
        )

    def test_create_phone_number_invalid(self):
        self.assertEqual(
            chalange2.create_phone_number([1, 2, 3]),
            "not a valid phone number",
        )


if __name__ == "__main__":
    unittest.main()

import React from "react";
import { screen } from "@testing-library/react";
import { render } from "./test-utils";
import { App } from "./App";

test("Login title", () => {
  render(<App />);
  const title = screen.getByText(/Login/i);
  expect(title).toBeInTheDocument();
});

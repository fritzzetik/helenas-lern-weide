import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// base = Repo-Name, weil GitHub Pages die Seite unter
// https://fritzzetik.github.io/helenas-lern-weide/ ausliefert.
export default defineConfig({
  plugins: [react()],
  base: "/helenas-lern-weide/",
});

// ===============================
// HEKAN Bible Website Script
// ===============================

// Current Year
const footer = document.querySelector("footer p:last-child");
if (footer) {
    footer.innerHTML = `© ${new Date().getFullYear()} HEKAN Bible`;
}

// Fade-in Animation
const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = "1";
            entry.target.style.transform = "translateY(0)";
        }
    });
}, {
    threshold: 0.15
});

document.querySelectorAll(".card, .gallery img, .heroLeft, .heroRight, .downloadSection").forEach((el) => {
    el.style.opacity = "0";
    el.style.transform = "translateY(40px)";
    el.style.transition = "all .8s ease";
    observer.observe(el);
});

// Screenshot Click Preview
document.querySelectorAll(".gallery img").forEach((img) => {
    img.addEventListener("click", () => {

        const overlay = document.createElement("div");

        overlay.style.position = "fixed";
        overlay.style.left = "0";
        overlay.style.top = "0";
        overlay.style.width = "100%";
        overlay.style.height = "100%";
        overlay.style.background = "rgba(0,0,0,.85)";
        overlay.style.display = "flex";
        overlay.style.justifyContent = "center";
        overlay.style.alignItems = "center";
        overlay.style.cursor = "zoom-out";
        overlay.style.zIndex = "9999";

        const preview = document.createElement("img");

        preview.src = img.src;
        preview.style.maxWidth = "90%";
        preview.style.maxHeight = "90%";
        preview.style.borderRadius = "20px";
        preview.style.boxShadow = "0 20px 60px rgba(0,0,0,.5)";

        overlay.appendChild(preview);

        overlay.onclick = () => overlay.remove();

        document.body.appendChild(overlay);

    });
});

// Download Counter
let downloads = localStorage.getItem("hekan_downloads") || 0;

document.querySelectorAll(".downloadBtn, .primary, .bigDownload").forEach((btn) => {

    btn.addEventListener("click", () => {

        downloads++;

        localStorage.setItem("hekan_downloads", downloads);

        console.log("Downloads:", downloads);

    });

});

// Navbar Shadow
window.addEventListener("scroll", () => {

    const header = document.querySelector("header");

    if (window.scrollY > 40) {

        header.style.boxShadow = "0 8px 25px rgba(0,0,0,.08)";

    } else {

        header.style.boxShadow = "none";

    }

});

// Smooth Button Hover
document.querySelectorAll("a").forEach((btn) => {

    btn.addEventListener("mouseenter", () => {

        btn.style.transition = ".3s";

    });

});

// Console Welcome
console.log("%cHEKAN Bible", "font-size:24px;font-weight:bold;color:#2563EB;");
console.log("%cRead God's Word Anytime, Anywhere.", "font-size:14px;color:#666;");
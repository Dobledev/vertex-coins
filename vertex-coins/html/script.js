const closeUI = () => {
    $("#coins-box").removeClass("show");
    document.activeElement?.blur();

    setTimeout(() => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        });
    }, 100);
};

window.addEventListener('message', (event) => {
    if (event.data?.action === "showCoins") {
        $("#coins-text").html(`<i class="fas fa-coins"></i> Coins: ${event.data.coins}`);
        $("#coins-box").addClass("show");
    }
});

$(document).on('keydown', (e) => {
    if (["Escape", "Delete"].includes(e.key)) closeUI();
});

$("#close-btn").on("click", closeUI);

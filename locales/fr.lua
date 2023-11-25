local Translations = {
    notifications = {
        success = {
            repaired = 'Véhicule réparé !',
            paid = 'Vous avez payé %{amount} depuis votre compte en banque'
        },
        error = {
            money = 'Vous n\'avez pas assez d\'argent !',
            alreadyInstalled = 'Vous avez déjà installé cette modification'
        },
        props = {
            installTitle = 'Customs'
        }
    },
    dragCam = {
        zoomIn = 'Zoomer',
        zoomOut = 'Dézoomer'
    },
    textUI = {
        tune = 'Appuyez sur [E] pour personnaliser votre voiture'
    },
    menus = {
        main = {
            title = 'Popcorn Customs',
            repair = 'Réparer',
            performance = 'Performance',
            parts = 'Cosmétiques - Pièces',
            colors = 'Cosmétiques - Couleurs',
            extras = 'Extras'
        },
        colors = {
            primary = 'Peinture primaire',
            secondary = 'Peinture secondaire',
            neon = 'Néon',
            cosmetics_colors = 'Cosmétiques - Couleurs'
        },
        neon = {
            title = 'Néon',
            neon = 'Néon %{label}, %{state}',
            color = 'Couleur du néon',
            installed = 'Néon %{neon} installé'
        },
        paint = {
            title = 'Cosmétiques - Pièces',
            primary = 'Peinture primaire',
            secondary = 'Peinture secondaire'
        },
        parts = {
            wheels = 'Roues',
        },
        performance = {
            title = 'Performance',
            turbo = 'Turbo',
        },
        wheels = {
            title = 'Roues',
            bikeRear = 'Roue arrière de moto',
            installed = '%{category} %{wheel} installé'
        },
        options = {
            interior = 'Intérieur',
            livery = 'Livrée',
            pearlescent = 'Nacrée',
            plateIndex = {
                title = 'Index de plaque',
                installed = 'Plaque %{plate} installée'
            },
            tyreSmoke = 'Fumée de pneus',
            wheelColor = 'Couleur des roues',
            windowTint = {
                title = 'Teinte des vitres',
                installed = '%{window} vitres installées'
            },
            xenon = {
                title = 'Xénon',
                installed = 'Xénon %{color} installé'
            }
        },
        general = {
            stock = 'Stock',
            enabled = 'Activé',
            disabled = 'Désactivé',
            installed = '%{element} installé',
            applied = '%{element} appliqué'
        },
    },
    general = {
        payReason = 'Customs',
    }
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end